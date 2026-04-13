import { useState, useEffect } from "react";
import { Link } from "react-router";
import {
  Users,
  MessageSquare,
  Crown,
  TrendingUp,
  Activity,
  DollarSign,
  UserCheck,
  AlertCircle,
} from "lucide-react";

export function AdminDashboard() {
  const [stats, setStats] = useState({
    totalUsers: 0,
    premiumUsers: 0,
    totalPosts: 0,
    activeUsers: 0,
  });

  useEffect(() => {
    // Load stats from localStorage
    const users = JSON.parse(localStorage.getItem("all_users") || "[]");
    const posts = JSON.parse(localStorage.getItem("forum_posts") || "[]");

    const premiumCount = users.filter((u: any) => u.isPremium).length;

    setStats({
      totalUsers: users.length,
      premiumUsers: premiumCount,
      totalPosts: posts.length,
      activeUsers: users.length, // Simple count for now
    });
  }, []);

  return (
    <div className="bg-gray-50 min-h-screen pb-24">
      {/* Header */}
      <div className="bg-gradient-to-br from-orange-600 via-red-600 to-pink-600 pt-8 pb-16 px-6 text-white relative rounded-b-[2.5rem] shadow-md">
        <div className="absolute top-0 left-0 w-full h-full overflow-hidden pointer-events-none opacity-20">
          <div className="absolute -top-10 -right-10 w-64 h-64 rounded-full bg-pink-500 blur-3xl"></div>
        </div>

        <div className="relative z-10">
          <div className="flex items-center gap-3 mb-6">
            <div className="w-12 h-12 bg-white/10 rounded-full flex items-center justify-center backdrop-blur-md border border-white/20">
              <Activity className="text-orange-300" size={24} />
            </div>
            <div>
              <p className="text-orange-200 text-xs">Quản trị viên</p>
              <h1 className="text-2xl font-extrabold">Admin Dashboard</h1>
            </div>
          </div>

          {/* Quick Stats */}
          <div className="grid grid-cols-2 gap-3">
            <div className="bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-4">
              <div className="flex items-center justify-between mb-2">
                <Users size={20} className="text-orange-300" />
                <span className="text-2xl font-extrabold">{stats.totalUsers}</span>
              </div>
              <p className="text-xs text-orange-100">Tổng người dùng</p>
            </div>

            <div className="bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-4">
              <div className="flex items-center justify-between mb-2">
                <Crown size={20} className="text-amber-300" />
                <span className="text-2xl font-extrabold">{stats.premiumUsers}</span>
              </div>
              <p className="text-xs text-orange-100">Premium Users</p>
            </div>

            <div className="bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-4">
              <div className="flex items-center justify-between mb-2">
                <MessageSquare size={20} className="text-pink-300" />
                <span className="text-2xl font-extrabold">{stats.totalPosts}</span>
              </div>
              <p className="text-xs text-orange-100">Bài viết forum</p>
            </div>

            <div className="bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-4">
              <div className="flex items-center justify-between mb-2">
                <UserCheck size={20} className="text-green-300" />
                <span className="text-2xl font-extrabold">{stats.activeUsers}</span>
              </div>
              <p className="text-xs text-orange-100">Hoạt động</p>
            </div>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="px-4 -mt-6 relative z-20 space-y-4">
        <div className="bg-white rounded-3xl shadow-sm border border-gray-100 p-5">
          <h3 className="font-bold text-gray-800 text-sm mb-4 flex items-center gap-2">
            <TrendingUp size={18} className="text-orange-500" />
            Quản lý nhanh
          </h3>

          <div className="space-y-2">
            <Link
              to="/admin/users"
              className="flex items-center justify-between p-4 rounded-xl hover:bg-orange-50 transition group border border-gray-100"
            >
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-orange-50 rounded-full flex items-center justify-center group-hover:bg-orange-100 transition">
                  <Users size={20} className="text-orange-600" />
                </div>
                <div>
                  <p className="font-bold text-gray-800 text-sm">Quản lý người dùng</p>
                  <p className="text-xs text-gray-500">{stats.totalUsers} người dùng</p>
                </div>
              </div>
              <div className="bg-orange-100 text-orange-600 px-3 py-1 rounded-lg text-xs font-bold">
                Xem
              </div>
            </Link>

            <Link
              to="/admin/forum"
              className="flex items-center justify-between p-4 rounded-xl hover:bg-purple-50 transition group border border-gray-100"
            >
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-purple-50 rounded-full flex items-center justify-center group-hover:bg-purple-100 transition">
                  <MessageSquare size={20} className="text-purple-600" />
                </div>
                <div>
                  <p className="font-bold text-gray-800 text-sm">Quản lý forum</p>
                  <p className="text-xs text-gray-500">{stats.totalPosts} bài viết</p>
                </div>
              </div>
              <div className="bg-purple-100 text-purple-600 px-3 py-1 rounded-lg text-xs font-bold">
                Xem
              </div>
            </Link>

            <Link
              to="/admin/premium"
              className="flex items-center justify-between p-4 rounded-xl hover:bg-amber-50 transition group border border-gray-100"
            >
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-amber-50 rounded-full flex items-center justify-center group-hover:bg-amber-100 transition">
                  <Crown size={20} className="text-amber-600" />
                </div>
                <div>
                  <p className="font-bold text-gray-800 text-sm">Quản lý Premium</p>
                  <p className="text-xs text-gray-500">{stats.premiumUsers} thành viên</p>
                </div>
              </div>
              <div className="bg-amber-100 text-amber-600 px-3 py-1 rounded-lg text-xs font-bold">
                Xem
              </div>
            </Link>
          </div>
        </div>

        {/* Recent Activity */}
        <div className="bg-white rounded-3xl shadow-sm border border-gray-100 p-5">
          <h3 className="font-bold text-gray-800 text-sm mb-4 flex items-center gap-2">
            <Activity size={18} className="text-blue-500" />
            Hoạt động gần đây
          </h3>

          <div className="space-y-3">
            <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl">
              <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                <Users size={14} className="text-blue-600" />
              </div>
              <div className="flex-1">
                <p className="text-xs font-bold text-gray-800">Người dùng mới đăng ký</p>
                <p className="text-[10px] text-gray-500">Vài phút trước</p>
              </div>
            </div>

            <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl">
              <div className="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center">
                <MessageSquare size={14} className="text-purple-600" />
              </div>
              <div className="flex-1">
                <p className="text-xs font-bold text-gray-800">Bài viết mới trong forum</p>
                <p className="text-[10px] text-gray-500">15 phút trước</p>
              </div>
            </div>

            <div className="flex items-center gap-3 p-3 bg-gray-50 rounded-xl">
              <div className="w-8 h-8 bg-amber-100 rounded-full flex items-center justify-center">
                <Crown size={14} className="text-amber-600" />
              </div>
              <div className="flex-1">
                <p className="text-xs font-bold text-gray-800">Nâng cấp Premium thành công</p>
                <p className="text-[10px] text-gray-500">1 giờ trước</p>
              </div>
            </div>
          </div>
        </div>

        {/* System Health */}
        <div className="bg-white rounded-3xl shadow-sm border border-gray-100 p-5">
          <h3 className="font-bold text-gray-800 text-sm mb-4 flex items-center gap-2">
            <AlertCircle size={18} className="text-green-500" />
            Tình trạng hệ thống
          </h3>

          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <span className="text-xs text-gray-600">Database</span>
              <span className="text-xs font-bold text-green-600 bg-green-50 px-2 py-1 rounded-md">
                Hoạt động tốt
              </span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-xs text-gray-600">API Server</span>
              <span className="text-xs font-bold text-green-600 bg-green-50 px-2 py-1 rounded-md">
                Hoạt động tốt
              </span>
            </div>
            <div className="flex items-center justify-between">
              <span className="text-xs text-gray-600">Storage</span>
              <span className="text-xs font-bold text-green-600 bg-green-50 px-2 py-1 rounded-md">
                Hoạt động tốt
              </span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
