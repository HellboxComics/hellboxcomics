export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    // --------------------------------------------------
    // HEALTH CHECK
    // --------------------------------------------------
    if (url.pathname === "/api/health") {
      return json({
        ok: true,
        service: "hellboxcomics",
        storage: {
          public: !!env.PUBLIC_BUCKET,
          private: !!env.PRIVATE_BUCKET,
        },
      });
    }

    // --------------------------------------------------
    // COMIC CATALOG
    // Example:
    // /api/comics
    //
    // This is the public catalog of comics currently
    // available on Hellbox Comics.
    // --------------------------------------------------
    if (url.pathname === "/api/comics") {
      return json({
        ok: true,
        comics: [
          {
            slug: "scivive",
            issue: 1,
            title: "SciVive",
            status: "published",
            access: "free",
            format: "ebook",
          },
          {
            slug: "ashbox",
            issue: 1,
            title: "Ashbox",
            status: "published",
          },
        ],
      });
    }

    // --------------------------------------------------
    // COMIC METADATA
    // Example:
    // /api/comics/ashbox/001
    // /api/comics/scivive/001
    // --------------------------------------------------
    const comicMatch = url.pathname.match(
      /^\/api\/comics\/([a-z0-9-]+)\/(\d+)$/
    );

    if (comicMatch) {
      const slug = comicMatch[1];
      const issue = comicMatch[2];

      const key = `comics/${slug}/${issue}/metadata/web/issue.json`;

      const object = await env.PUBLIC_BUCKET.get(key);

      if (!object) {
        return json(
          {
            ok: false,
            error: "Comic metadata not found",
            slug,
            issue: Number(issue),
          },
          404
        );
      }

      const metadata = await object.json();

      return json(metadata);
    }

    // --------------------------------------------------
    // FALL BACK TO STATIC WEBSITE
    // --------------------------------------------------
    return env.ASSETS.fetch(request);
  },
};

function json(data, status = 200) {
  return new Response(JSON.stringify(data, null, 2), {
    status,
    headers: {
      "Content-Type": "application/json; charset=utf-8",
      "Cache-Control": "public, max-age=300",
    },
  });
}
