import { useState, useEffect } from "react";
import { Search, MessageSquare, Trash2, Eye, User, Clock } from "lucide-react";

interface ForumPost {
  id: string;
  author: string;
  title: string;
  content: string;
  timestamp: number;
  replies?: number;
}

export function ForumManagement() {
  const [posts, setPosts] = useState<ForumPost[]>([]);
  const [searchQuery, setSearchQuery] = useState("");

  useEffect(() => {
    loadPosts();
  }, []);

  const loadPosts = () => {
    const forumPosts = JSON.parse(localStorage.getItem("forum_posts") || "[]");
    setPosts(forumPosts);
  };

  const deletePost = (postId: string) => {
    if (confirm("Bạn có chắc muốn xóa bài viết này?")) {
      const updatedPosts = posts.filter((p) => p.id !== postId);
      localStorage.setItem("forum_posts", JSON.stringify(updatedPosts));
      setPosts(updatedPosts);
    }
  };

  const filteredPosts = posts.filter(
    (post) =>
      post.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      post.author.toLowerCase().includes(searchQuery.toLowerCase()) ||
      post.content.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const formatTime = (timestamp: number) => {
    const date = new Date(timestamp);
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const minutes = Math.floor(diff / 60000);
    const hours = Math.floor(minutes / 60);
    const days = Math.floor(hours / 24);

    if (days > 0) return `${days} ngày trước`;
    if (hours > 0) return `${hours} giờ trước`;
    if (minutes > 0) return `${minutes} phút trước`;
    return "Vừa xong";
  };

  return (
    <div className="bg-gray-50 min-h-screen pb-24">
      {/* Header */}
      <div className="bg-gradient-to-br from-orange-600 via-red-600 to-pink-600 pt-8 pb-12 px-6 text-white relative rounded-b-[2.5rem] shadow-md">
        <div className="absolute top-0 left-0 w-full h-full overflow-hidden pointer-events-none opacity-20">
          <div className="absolute -top-10 -right-10 w-64 h-64 rounded-full bg-pink-500 blur-3xl"></div>
        </div>

        <div className="relative z-10">
          <h1 className="text-2xl font-extrabold mb-2">Quản lý Forum</h1>
          <p className="text-orange-100 text-sm">
            {filteredPosts.length} bài viết
          </p>
        </div>
      </div>

      <div className="px-4 -mt-6 relative z-20 space-y-4">
        {/* Search */}
        <div className="bg-white rounded-3xl shadow-sm border border-gray-100 p-4">
          <div className="relative">
            <Search
              size={18}
              className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
            />
            <input
              type="text"
              placeholder="Tìm kiếm bài viết..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 text-sm"
            />
          </div>
        </div>

        {/* Posts List */}
        <div className="space-y-3">
          {filteredPosts.length === 0 ? (
            <div className="bg-white rounded-3xl shadow-sm border border-gray-100 p-8 text-center">
              <MessageSquare size={48} className="text-gray-300 mx-auto mb-3" />
              <p className="text-gray-500 text-sm">Không có bài viết nào</p>
            </div>
          ) : (
            filteredPosts.map((post) => (
              <div
                key={post.id}
                className="bg-white rounded-2xl shadow-sm border border-gray-100 p-4"
              >
                <div className="flex items-start gap-3 mb-3">
                  <div className="w-10 h-10 bg-gradient-to-br from-purple-500 to-pink-500 rounded-full flex items-center justify-center text-white font-bold text-sm flex-shrink-0">
                    {post.author.charAt(0).toUpperCase()}
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-1">
                      <h3 className="font-bold text-gray-800 text-sm truncate">
                        {post.title}
                      </h3>
                    </div>
                    <p className="text-xs text-gray-500 flex items-center gap-1 mb-2">
                      <User size={10} />
                      {post.author}
                      <span className="mx-1">•</span>
                      <Clock size={10} />
                      {formatTime(post.timestamp)}
                    </p>
                    <p className="text-xs text-gray-600 line-clamp-2">
                      {post.content}
                    </p>
                  </div>
                </div>

                <div className="flex gap-2 pt-3 border-t border-gray-100">
                  <button
                    onClick={() => {
                      alert(
                        `Tiêu đề: ${post.title}\n\nNội dung:\n${post.content}\n\nTác giả: ${post.author}\nThời gian: ${formatTime(post.timestamp)}`
                      );
                    }}
                    className="flex-1 flex items-center justify-center gap-2 py-2 px-3 rounded-lg text-xs font-bold bg-blue-50 text-blue-600 hover:bg-blue-100 transition"
                  >
                    <Eye size={14} />
                    Xem chi tiết
                  </button>
                  <button
                    onClick={() => deletePost(post.id)}
                    className="flex items-center justify-center gap-2 py-2 px-4 rounded-lg text-xs font-bold bg-red-50 text-red-600 hover:bg-red-100 transition"
                  >
                    <Trash2 size={14} />
                    Xóa
                  </button>
                </div>

                {post.replies !== undefined && post.replies > 0 && (
                  <div className="mt-3 pt-3 border-t border-gray-100">
                    <p className="text-xs text-gray-500">
                      <MessageSquare size={10} className="inline mr-1" />
                      {post.replies} phản hồi
                    </p>
                  </div>
                )}
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
