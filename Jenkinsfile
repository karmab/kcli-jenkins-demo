properties(
 [
  parameters (
    [
    booleanParam(name: 'wait', defaultValue: false, description: 'Wait for plan to finish'),
    string(name: 'kcli_config_yml', defaultValue: "kcli_config_yml", description: 'Secret File Credential storing your ~/.kcli/config.yml'),
    string(name: 'kcli_id_rsa', defaultValue: "kcli_id_rsa", description: 'Secret File Credential storing your private key'),
    string(name: 'kcli_id_rsa_pub', defaultValue: "kcli_id_rsa_pub", description: 'Secret File Credential container your public key'),
    string(name: 'prefix', defaultValue: "prout", description: ''),
    string(name: 'image', defaultValue: "CentOS-7-x86_64-GenericCloud.qcow2", description: ''),
    string(name: 'pool', defaultValue: "default", description: ''),
    string(name: 'network', defaultValue: "default", description: ''),
    ]
  ),
 ]
)

pipeline {
    agent any
    environment {
     KCLI_CONFIG = credentials(${params.kcli_config_yml})
     KCLI_SSH_ID_RSA = credentials(${params.kcli_id_rsa})
     KCLI_SSH_ID_RSA_PUB = credentials(${params.kcli_id_rsa_pub})
     KCLI_PARAMETERS = "-P prefix=${params.prefix} -P image=${params.image} -P pool=${params.pool} -P network=${params.network}"
     CONTAINER_OPTIONS = "--net host --rm --security-opt label=disable -v $HOME/.kcli:/root/.kcli -v $HOME/.ssh:/root/.ssh -v $PWD:/workdir -v /var/tmp:/ignitiondir"
     KCLI = "docker run ${CONTAINER_OPTIONS} karmab/kcli"
    }
    stages {
        stage('Prepare kcli environment') {
            steps {
                sh '''
                [ -d $HOME/.kcli ] && rm -rf $HOME/.kcli
                mkdir $HOME/.kcli
                cp "$KCLI_CONFIG" $HOME/.kcli/config.yml
                cp "$KCLI_SSH_ID_RSA" $HOME/.kcli/id_rsa
                cp "$KCLI_SSH_ID_RSA_PUB" $HOME/.kcli/id_rsa.pub
                '''
            }
        }
        stage('Check kcli client') {
            steps {
                sh '${KCLI} client'
            }
        }
        stage('Deploy kcli plan') {
            steps {
                script {
                  if ( "${params.wait}" == "true" ) {
                     WAIT = "--wait"
                  } else {
                     WAIT = ""
                  }
                }
                sh """
                  ${KCLI} create plan -f ${WORKSPACE}/kcli_plan.yml ${KCLI_PARAMETERS} ${WAIT} ${env.JOB_NAME}_${env.BUILD_NUMBER}
                """
            }
        }
    }
}
