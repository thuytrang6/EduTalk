const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { initializeApp } = require("firebase-admin/app");
const { getFirestore, FieldValue } = require("firebase-admin/firestore");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

/**
 * Hàm tự động chạy khi có comment mới được tạo trong một bài viết.
 * Sẽ gửi Push Notification đến chủ bài viết và lưu vào lịch sử thông báo.
 */
exports.onCommentCreated = onDocumentCreated(
  "posts/{postId}/comments/{commentId}",
  async (event) => {
    const db = getFirestore();
    const messaging = getMessaging();

    const postId = event.params.postId;
    const commentData = event.data?.data();

    if (!commentData) {
      console.log("Không có dữ liệu comment.");
      return null;
    }

    const commenterName = commentData.authorName || "Ai đó";
    const commentContent = commentData.content || "(hình ảnh)";
    const commenterId = commentData.authorId;

    try {
      // 1. Lấy thông tin bài viết để tìm authorId
      const postDoc = await db.collection("posts").doc(postId).get();
      if (!postDoc.exists) {
        console.log(`Bài viết ${postId} không tồn tại.`);
        return null;
      }

      const authorId = postDoc.data()?.authorId;

      // Không gửi thông báo nếu người comment là chính tác giả
      if (!authorId || authorId === commenterId) {
        console.log("Người comment là chính tác giả hoặc không có authorId.");
        return null;
      }

      // 2. Lấy FCM Token của tác giả bài viết
      const authorDoc = await db.collection("users").doc(authorId).get();
      if (!authorDoc.exists) {
        console.log(`User ${authorId} không tồn tại.`);
        return null;
      }

      const fcmToken = authorDoc.data()?.fcmToken;

      // 3. Gửi Push Notification (nếu có FCM Token)
      if (fcmToken) {
        const message = {
          token: fcmToken,
          notification: {
            title: "Có bình luận mới 💬",
            body: `${commenterName}: ${commentContent.substring(0, 80)}`,
          },
          data: {
            postId: postId,
            type: "new_comment",
          },
          android: {
            priority: "high",
            notification: {
              channelId: "edutalk_notifications",
              clickAction: "FLUTTER_NOTIFICATION_CLICK",
            },
          },
        };

        try {
          await messaging.send(message);
          console.log(`✅ Push Notification đã gửi đến ${authorId}`);
        } catch (fcmError) {
          // Token hết hạn hoặc thiết bị không hoạt động — không crash hàm
          console.warn(`⚠️ Gửi FCM thất bại: ${fcmError.message}`);
        }
      } else {
        console.log(`User ${authorId} chưa có FCM Token.`);
      }

      // 4. Lưu thông báo vào Firestore (users/{authorId}/notifications)
      await db
        .collection("users")
        .doc(authorId)
        .collection("notifications")
        .add({
          title: "Có bình luận mới",
          content: `${commenterName} đã bình luận: "${commentContent.substring(0, 100)}"`,
          postId: postId,
          commenterId: commenterId,
          commenterName: commenterName,
          isRead: false,
          createdAt: FieldValue.serverTimestamp(),
          type: "new_comment",
        });

      console.log(`✅ Đã lưu thông báo vào Firestore cho user ${authorId}`);
      return null;
    } catch (error) {
      console.error("❌ Lỗi trong onCommentCreated:", error);
      return null;
    }
  }
);
