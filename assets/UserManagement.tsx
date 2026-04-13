import { useState, useEffect } from "react";
import { Search, User, Crown, Mail, Calendar, Trash2 } from "lucide-react";

interface UserData {
  username: string;
  email?: string;
  isPremium: boolean;
  isAdmin: boolean;
  joinDate?: string;
  trialsRemaining?: number;
}

export function UserManagement() {
  const [users, setUsers] = useState<UserData[]>([]);
  const [searchQuery, setSearchQuery] = useState("");
  const [filterType, setFilterType] = useState<"all" | "premium" | "free" | "admin">("all");

  useEffect(() => {
    loadUsers();
  }, []);

  const loadUsers = () => {
    const allUsers = JSON.parse(localStorage.getItem("all_users") || "[]");
    setUsers(allUsers);
  };

  const deleteUser = (username: string) => {
    if (confirm(`Bạn có chắc muốn xóa người dùng "${username}"?`)) {
      const updatedUsers = users.filter((u) => u.username !== username);
      localStorage.setItem("all_users", JSON.stringify(updatedUsers));
      setUsers(updatedUsers);
    }
  };

  const togglePremium = (username: string) => {
    const updatedUsers = users.map((u) =>
      u.username === username ? { ...u, isPremium: !u.isPremium } : u
    );
    localStorage.setItem("all_users", JSON.stringify(updatedUsers));
    setUsers(updatedUsers);
  };

  const toggleAdmin = (username: string) => {
    const updatedUsers = users.map((u) =>
      u.username === username ? { ...u, isAdmin: !u.isAdmin } : u
    );
    localStorage.setItem("all_users", JSON.stringify(updatedUsers));
    setUsers(updatedUsers);
  };

  const filteredUsers = users
    .filter((user) => !user.isAdmin) // Hide admin users
    .filter((user) => {
      if (filterType === "premium") return user.isPremium;
      if (filterType === "free") return !user.isPremium;
      return true;
    })
    .filter((user) =>
      user.username.toLowerCase().includes(searchQuery.toLowerCase())
    );

  return (
    <div className="bg-gray-50 min-h-screen pb-24">
      {/* Header */}
      <div className="bg-gradient-to-br from-orange-600 via-red-600 to-pink-600 pt-8 pb-12 px-6 text-white relative rounded-b-[2.5rem] shadow-md">
        <div className="absolute top-0 left-0 w-full h-full overflow-hidden pointer-events-none opacity-20">
          <div className="absolute -top-10 -right-10 w-64 h-64 rounded-full bg-pink-500 blur-3xl"></div>
        </div>

        <div className="relative z-10">
          <h1 className="text-2xl font-extrabold mb-2">Quản lý người dùng</h1>
          <p className="text-orange-100 text-sm">
            {filteredUsers.length} người dùng
          </p>
        </div>
      </div>

      <div className="px-4 -mt-6 relative z-20 space-y-4">
        {/* Search & Filter */}
        <div className="bg-white rounded-3xl shadow-sm border border-gray-100 p-4">
          <div className="relative mb-3">
            <Search
              size={18}
              className="absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"
            />
            <input
              type="text"
              placeholder="Tìm kiếm người dùng..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-orange-400 text-sm"
            />
          </div>

          <div className="flex gap-2 overflow-x-auto pb-1">
            {[
              { key: "all", label: "Tất cả" },
              { key: "premium", label: "Premium" },
              { key: "free", label: "Miễn phí" },
            ].map((filter) => (
              <button
                key={filter.key}
                onClick={() => setFilterType(filter.key as any)}
                className={`px-4 py-2 rounded-lg text-xs font-bold whitespace-nowrap transition ${
                  filterType === filter.key
                    ? "bg-orange-500 text-white"
                    : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                }`}
              >
                {filter.label}
              </button>
            ))}
          </div>
        </div>

        {/* Users List */}
        <div className="space-y-3">
          {filteredUsers.length === 0 ? (
            <div className="bg-white rounded-3xl shadow-sm border border-gray-100 p-8 text-center">
              <User size={48} className="text-gray-300 mx-auto mb-3" />
              <p className="text-gray-500 text-sm">Không tìm thấy người dùng</p>
            </div>
          ) : (
            filteredUsers.map((user, index) => (
              <div
                key={index}
                className="bg-white rounded-2xl shadow-sm border border-gray-100 p-4"
              >
                <div className="flex items-start justify-between mb-3">
                  <div className="flex items-center gap-3">
                    <div className="w-12 h-12 bg-gradient-to-br from-blue-500 to-purple-500 rounded-full flex items-center justify-center text-white font-bold text-lg">
                      {user.username.charAt(0).toUpperCase()}
                    </div>
                    <div>
                      <div className="flex items-center gap-2">
                        <h3 className="font-bold text-gray-800 text-sm">
                          {user.username}
                        </h3>
                        {user.isPremium && (
                          <Crown size={14} className="text-amber-500" />
                        )}
                      </div>
                      {user.email && (
                        <p className="text-xs text-gray-500 flex items-center gap-1 mt-1">
                          <Mail size={10} />
                          {user.email}
                        </p>
                      )}
                      {user.joinDate && (
                        <p className="text-xs text-gray-500 flex items-center gap-1 mt-1">
                          <Calendar size={10} />
                          Tham gia: {user.joinDate}
                        </p>
                      )}
                    </div>
                  </div>
                </div>

                <div className="flex gap-2">
                  <button
                    onClick={() => togglePremium(user.username)}
                    className={`flex-1 py-2 px-3 rounded-lg text-xs font-bold transition ${
                      user.isPremium
                        ? "bg-amber-100 text-amber-700 hover:bg-amber-200"
                        : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                    }`}
                  >
                    {user.isPremium ? "Hủy Premium" : "Cấp Premium"}
                  </button>
                  <button
                    onClick={() => deleteUser(user.username)}
                    className="py-2 px-3 rounded-lg text-xs font-bold bg-red-50 text-red-600 hover:bg-red-100 transition flex items-center gap-1"
                  >
                    <Trash2 size={14} />
                    Xóa
                  </button>
                </div>

                {!user.isPremium && user.trialsRemaining !== undefined && (
                  <div className="mt-3 pt-3 border-t border-gray-100">
                    <p className="text-xs text-gray-500">
                      Lượt dùng thử còn lại:{" "}
                      <span className="font-bold text-gray-700">
                        {user.trialsRemaining}/3
                      </span>
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
