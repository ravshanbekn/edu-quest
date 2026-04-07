import { Outlet } from "react-router-dom";
import { Sidebar } from "./Sidebar";
import { Footer } from "./Footer";

export function AppLayout() {
  return (
    // h-screen + overflow-hidden: корневой контейнер не скроллится сам
    // flex: sidebar слева, контент справа
    <div className="h-screen flex overflow-hidden">
      <Sidebar />
      {/* Правая часть скроллится независимо — sidebar остаётся на месте */}
      <div className="flex flex-col flex-1 min-w-0 overflow-y-auto">
        <main className="flex-1 p-6">
          <div className="max-w-7xl mx-auto">
            <Outlet />
          </div>
        </main>
        <Footer />
      </div>
    </div>
  );
}
