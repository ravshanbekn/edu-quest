import { useState } from "react";
import { DEFAULT_PAGE_SIZE } from "@/lib/constants";

export function usePagination(initialSize = DEFAULT_PAGE_SIZE) {
  const [page, setPage] = useState(0);
  const [size] = useState(initialSize);

  return { page, size, setPage };
}
