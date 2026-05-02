import { Link } from "react-router-dom";
import { SearchX } from "lucide-react";

export function NotFoundPage() {
  return (
    <div className="flex flex-col items-center justify-center py-24 text-center px-4">
      <SearchX className="h-16 w-16 text-muted-foreground/40 mb-6" />
      <h1 className="text-3xl font-bold mb-2">404</h1>
      <p className="text-lg text-muted-foreground mb-1">Page not found</p>
      <p className="text-sm text-muted-foreground mb-8">
        It may have been removed or you followed a broken link.
      </p>
      <Link
        to="/courses"
        className="px-5 py-2 text-sm rounded-md bg-primary text-primary-foreground hover:bg-primary/90 transition-colors"
      >
        Go home
      </Link>
    </div>
  );
}
