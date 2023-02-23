SELECT author_name,
  SUM(frontend) AS frontend_count,
  SUM(backend) AS backend_count,
  SUM(frontend + backend) AS total_count,
  TO_CHAR(
    (
      (
        SUM(frontend)::DOUBLE PRECISION / SUM(frontend + backend)
      )::DOUBLE PRECISION * 100
    ),
    '999.9'
  ) AS frontend_percent,
  TO_CHAR(
    (
      (
        SUM(backend)::DOUBLE PRECISION / SUM(frontend + backend)
      )::DOUBLE PRECISION * 100
    ),
    '999.9'
  ) AS backend_percent
FROM (
    SELECT author_name,
      ext,
      CASE
        WHEN ext IN (
          'tsx',
          'html',
          'scss',
          'ts',
          'css',
          'js'
        ) THEN 1
        ELSE 0
      END AS frontend,
      CASE
        WHEN ext IN ('ex', 'exs') THEN 1
        ELSE 0
      END AS backend
    FROM (
        SELECT c.author_name,
          SUBSTRING(
            f.file_path
            from '\.([^\.]*)$'
          ) AS ext
        FROM git_commit_stats f,
          git_commits c
        WHERE f.commit_hash = c.hash
          AND c.author_when >= '2022-07-01'
          AND c.author_when < '2023-01-01'
          AND c.author_name != 'dependabot[bot]'
          AND c.author_name != 'github-actions[bot]'
      ) AS foo
    WHERE ext IN (
        'tsx',
        'html',
        'exs',
        'ex',
        'scss',
        'ts',
        'css',
        'js'
      )
  ) AS foo2
GROUP BY 1;