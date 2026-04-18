import { useState, useEffect } from "react";
import { Search, Crown, User, Mail, DollarSign, Calendar, TrendingUp } from "lucide-react";

interface PremiumUser {
  username: string;
  email?: string;
  premiumSince?: string;
  revenue?: number;
}

export function PremiumManagement() {
  const [premiumUsers, setPremiumUsers] = useState<PremiumUser[]>([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [totalRevenue, setTotalRevenue] = useState(0);

  useEffect(() => {
    loadPremiumUsers();
  }, []);

  const loadPremiumUsers = () => {
    const allUsers = JSON.parse(localStorage.getItem("all_users") || "[]");
    const premium = allUsers.filter((u: any) => u.isPremium);

    // Calculate total revenue (mock data)
    const revenue = premium.length * 199000; // 199k per premium user
    setTotalRevenue(revenue);
    setPremiumUsers(premium);
  };

  const filteredUsers = premiumUsers.filter((user) =>
    user.username.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("vi-VN", {
      style: "currency",
      currency: "VND",
    }).format(amount);
  };

  return (
    <div className="bg-gray-50 min-h-screen pb-24">
      {/* Header */}
      <div className="bg-gradient-to-br from-orange-600 via-red-600 to-pink-600 pt-8 pb-16 px-6 text-white relative rounded-b-[2.5rem] shadow-md">
        <div className="absolute top-0 left-0 w-full h-full overflow-hidden pointer-events-none opacity-20">
          <div className="absolute -top-10 -right-10 w-64 h-64 rounded-full bg-pink-500 blur-3xl"></div>
        </div>

        <div className="relative z-10">
          <h1 className="text-2xl font-extrabold mb-4">Quản lý Premium</h1>

          {/* Revenue Stats */}
          <div className="grid grid-cols-2 gap-3">
            <div className="bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-4">
              <div className="flex items-center gap-2 mb-2">
                <Crown size={18} className="text-amber-300" />
                <span className="text-xs text-orange-100">Thành viên</span>
              </div>
              <p className="text-2xl font-extrabold">{premiumUsers.length}</p>
            </div>

            <div className="bg-white/10 backdrop-blur-md border border-white/20 rounded-2xl p-4">
              <div className="flex items-center gap-2 mb-2">
                <DollarSign size={18} className="text-green-300" />
                <span className="text-xs text-orange-100">Doanh thu</span>
              </div>
              <p className="text-lg font-extrabold">
                {(totalRevenue / 1000000).toFixed(1)}M
              </p>
            </div>
          </div>
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
              placeholder="Tìm kiếm thành viên Premium..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 text-sm"
            />
          </div>
        </div>

        {/* Stats Card */}
        <div className="bg-white rounded-3xl shadow-sm border border-gray-100 p-5">
          <h3 className="font-bold text-gray-800 text-sm mb-4 flex items-center gap-2">
            <TrendingUp size={18} className="text-green-500" />
            Thống kê doanh thu
          </h3>

          <div className="space-y-3">
            <div className="flex items-center justify-between p-3 bg-gradient-to-r from-amber-50 to-orange-50 rounded-xl border border-amber-100">
              <span className="text-xs font-bold text-gray-700">
                Tổng doanh thu
              </span>
              <span className="text-sm font-extrabold text-amber-600">
                {formatCurrency(totalRevenue)}
              </span>
            </div>

            <div className="flex items-center justify-between p-3 bg-gray-50 rounded-xl">
              <span className="text-xs text-gray-600">Gói Premium</span>
              <span className="text-xs font-bold text-gray-700">
                {formatCurrency(199000)}
              </span>
            </div>

            <div className="flex items-center justify-between p-3 bg-gray-50 rounded-xl">
              <span className="text-xs text-gray-600">TB/người dùng</span>
              <span className="text-xs font-bold text-gray-700">
                {formatCurrency(199000)}
              </span>
            </div>
          </div>
        </div>

        {/* Premium Users List */}
        <div className="space-y-3">
          {filteredUsers.length === 0 ? (
            <div className="bg-white rounded-3xl shadow-sm border border-gray-100 p-8 text-center">
              <Crown size={48} className="text-gray-300 mx-auto mb-3" />
              <p className="text-gray-500 text-sm">
                Chưa có thành viên Premium
              </p>
            </div>
          ) : (
            filteredUsers.map((user, index) => (
              <div
                key={index}
                className="bg-white rounded-2xl shadow-sm border border-gray-100 p-4"
              >
                <div className="flex items-center gap-3">
                  <div className="w-12 h-12 bg-gradient-to-br from-amber-400 to-orange-500 rounded-full flex items-center justify-center text-white font-bold text-lg shadow-lg">
                    {user.username.charAt(0).toUpperCase()}
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h3 className="font-bold text-gray-800 text-sm">
                        {user.username}
                      </h3>
                      <Crown size={14} className="text-amber-500" />
                    </div>
                    {user.email && (
                      <p className="text-xs text-gray-500 flex items-center gap-1">
                        <Mail size={10} />
                        {user.email}
                      </p>
                    )}
                    {user.premiumSince && (
                      <p className="text-xs text-gray-500 flex items-center gap-1 mt-1">
                        <Calendar size={10} />
                        Premium từ: {user.premiumSince}
                      </p>
                    )}
                  </div>
                  <div className="text-right">
                    <p className="text-xs text-gray-500">Đóng góp</p>
                    <p className="text-sm font-bold text-green-600">
                      {formatCurrency(user.revenue || 199000)}
                    </p>
                  </div>
                </div>
              </div>
            ))
          )}
        </div>
      </div>
    </div>
  );
}
