#!groovy

def checkout_git_repo(repo_url, branch, target_dir) {
  checkout poll: false, 
    scm: [
      $class: 'GitSCM', 
      branches: [[name: branch]], 
      doGenerateSubmoduleConfigurations: false, 
      extensions: [
        [
          $class: 'CloneOption', 
          depth: 0, 
          noTags: true, 
          reference: '', 
          shallow: true
        ], 
        [
          $class: 'RelativeTargetDirectory', 
          relativeTargetDir: target_dir
        ]
      ], 
      submoduleCfg: [], 
      userRemoteConfigs: [[url: repo_url]]
    ]
}

def tf_scaffold(aws_creds, action, project, environment, component, bucket_prefix, aws_region, tf_log_level, terraform_args) {
  withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                            credentialsId: aws_creds,
                            accessKeyVariable: 'aws_access_key',
                            secretKeyVariable: 'aws_secret_key']]) {
    withEnv([
      "AWS_DEFAULT_REGION=${aws_region}",
      "AWS_ACCESS_KEY_ID=${env.aws_access_key}",
      "AWS_SECRET_ACCESS_KEY=${env.aws_secret_key}",
      "TF_LOG=${tf_log_level}"
    ]) {
      sh """
        pwd;
        tree -L 3;
        terraform -version;
        bash ./bin/terraform.sh \
          --action ${action} \
          --project ${project} \
          --environment ${environment} \
          --component ${component} \
          --bucket-prefix ${bucket_prefix} \
          --region ${aws_region} \
          -- ${terraform_args};
      """
    } //withEnv
  } //withCredentials
}

return this
