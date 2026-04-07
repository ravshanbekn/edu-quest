import { ChevronLeft, ChevronRight } from "lucide-react";
import type { Page } from "@/types/common.types";

interface Column<T> {
  key: string;
  header: string;
  render: (item: T) => React.ReactNode;
}

interface DataTableProps<T> {
  data: Page<T> | undefined;
  columns: Column<T>[];
  isLoading?: boolean;
  onPageChange: (page: number) => void;
}

export function DataTable<T>({
  data,
  columns,
  isLoading,
  onPageChange,
}: DataTableProps<T>) {
  if (isLoading) {
    return (
      <div className="border rounded-lg p-8 text-center text-muted-foreground">
        Загрузка...
      </div>
    );
  }

  if (!data || data.empty) {
    return (
      <div className="border rounded-lg p-8 text-center text-muted-foreground">
        Нет данных
      </div>
    );
  }

  return (
    <div className="space-y-4">
      <div className="border rounded-lg overflow-hidden">
        <table className="w-full text-sm">
          <thead className="bg-muted/50">
            <tr>
              {columns.map((col) => (
                <th key={col.key} className="text-left px-4 py-3 font-medium">
                  {col.header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {data.content.map((item, idx) => (
              <tr key={idx} className="border-t hover:bg-muted/30">
                {columns.map((col) => (
                  <td key={col.key} className="px-4 py-3">
                    {col.render(item)}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {data.totalPages > 1 && (
        <div className="flex items-center justify-between text-sm">
          <span className="text-muted-foreground">
            Страница {data.number + 1} из {data.totalPages} ({data.totalElements} записей)
          </span>
          <div className="flex gap-1">
            <button
              onClick={() => onPageChange(data.number - 1)}
              disabled={data.first}
              className="p-2 rounded-md hover:bg-muted disabled:opacity-30"
            >
              <ChevronLeft className="h-4 w-4" />
            </button>
            <button
              onClick={() => onPageChange(data.number + 1)}
              disabled={data.last}
              className="p-2 rounded-md hover:bg-muted disabled:opacity-30"
            >
              <ChevronRight className="h-4 w-4" />
            </button>
          </div>
        </div>
      )}
    </div>
  );
}
