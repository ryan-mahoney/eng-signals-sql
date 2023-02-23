SELECT name,
  TO_CHAR(AVG(days_to_merge), '99.9') AS avg_pr_lead_time,
  WIDTH_BUCKET(AVG(days_to_merge), 0, 8, 5) AS days_to_merge_bucket
FROM (
    SELECT COALESCE(
        github_pull_requests.author_name,
        github_pull_requests.author_login
      ) AS name,
      github_pull_requests.url,
      MIN(github_pull_request_commits.author_when) AS first_author_when,
      github_pull_requests.created_at,
      github_pull_requests.merged_at,
      github_pull_requests.additions,
      github_pull_requests.deletions,
      extract(
        EPOCH
        FROM (
            github_pull_requests.merged_at - MIN(github_pull_request_commits.author_when)
          )
      )::integer / 60 / 60 / 24 AS days_to_merge
    FROM github_pull_requests
      INNER JOIN github_pull_request_commits ON github_pull_requests.repo_id = github_pull_request_commits.repo_id
      AND github_pull_requests.number = github_pull_request_commits.pr_number
      INNER JOIN repos ON github_pull_requests.repo_id = repos.id
    WHERE github_pull_requests.created_at >= '2022-07-01'
      AND github_pull_requests.created_at < '2023-01-01'
      AND github_pull_requests.state = 'MERGED'
      AND github_pull_requests.author_login != 'dependabot'
      AND github_pull_requests.author_login != 'github-actions'
      AND COALESCE(
        github_pull_requests.author_name,
        github_pull_requests.author_login
      ) IN (
        SELECT COALESCE(author_name, author_login)
        FROM github_pull_requests
        WHERE created_at >= '2022-07-01'
          AND created_at < '2022-09-01'
      )
      AND COALESCE(
        github_pull_requests.author_name,
        github_pull_requests.author_login
      ) IN (
        SELECT COALESCE(author_name, author_login)
        FROM github_pull_requests
        WHERE created_at >= '2022-11-01'
      )
    GROUP BY 1,
      2,
      4,
      5,
      6,
      7
  ) as foo
WHERE days_to_merge < 30
GROUP BY name
ORDER BY 3;