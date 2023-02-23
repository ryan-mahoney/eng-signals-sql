SELECT author_name,
  CASE
    WHEN SUM(devops) > 0 THEN 'DevOps'
    ELSE 'Not DevOps'
  END AS devops_count
FROM (
    SELECT author_name,
      ext,
      CASE
        WHEN ext = 'tf' THEN 1
        ELSE 0
      END AS devops
    FROM (
        SELECT c.author_name,
          SUBSTRING(
            f.file_path
            from '\.([^\.]*)$'
          ) AS ext
        FROM git_commit_stats f,
          git_commits c
        WHERE f.commit_hash = c.hash
          AND c.author_when >= '2022-07-01' --AND c.author_when < '2023-01-01'
          AND c.author_name != 'dependabot[bot]'
          AND c.author_name != 'github-actions[bot]'
          AND c.author_name != 'renovate[bot]'
      ) AS foo
    WHERE ext IN (
        'tf',
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