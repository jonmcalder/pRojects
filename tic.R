add_package_checks()

get_stage("after_success") %>%
  add_code_step(covr::coveralls(quiet = FALSE))

if (Sys.getenv("id_rsa") != "") {

  get_stage("before_deploy") %>%
    add_step(step_setup_ssh())

  if (ci()$get_branch() == "master") {
    get_stage("deploy") %>%
      add_code_step(covr::codecov()) %>%
      add_code_step(devtools::install()) %>%
      add_code_step(install.packages("spelling")) %>%
      add_code_step(covrpage::covrpage_ci()) %>%
      add_step(step_push_deploy(commit_paths = "tests/README.md")) %>%
      add_step(step_build_pkgdown()) %>%
      add_step(step_push_deploy(path = "docs", branch = "gh-pages")) %>%
      add_code_step(library("starters"))%>%
      add_code_step(get_project_health()) %>%
      add_step(step_push_deploy(path = "health", branch = "project-health"))
  }else{
    get_stage("deploy") %>%
      add_code_step(covr::codecov()) %>%
      add_code_step(devtools::install()) %>%
      add_code_step(covrpage::covrpage_ci()) %>%
      add_step(step_push_deploy(commit_paths = "tests/README.md"))
  }
}
