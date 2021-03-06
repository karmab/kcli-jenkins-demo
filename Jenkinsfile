properties(
 [
  parameters (
    [
    booleanParam(name: 'wait', defaultValue: false, description: 'Wait for plan to finish'),
    string(name: 'kcli_client', defaultValue: "", description: 'Target Kcli client. Default one will be used if empty'),
    string(name: 'kcli_config_yml', defaultValue: "kcli-config-yml", description: 'Secret File Credential storing your ~/.kcli/config.yml'),
    string(name: 'kcli_id_rsa', defaultValue: "kcli-id-rsa", description: 'Secret File Credential storing your private key'),
    string(name: 'kcli_id_rsa_pub', defaultValue: "kcli-id-rsa-pub", description: 'Secret File Credential container your public key'),
    string(name: 'prefix', defaultValue: "prout", description: ''),
    string(name: 'image', defaultValue: "CentOS-7-x86_64-GenericCloud.qcow2", description: ''),
    string(name: 'pool', defaultValue: "default", description: ''),
    string(name: 'network', defaultValue: "default", description: ''),
    string(name: 'vms', defaultValue: "1", description: ''),
    ]
  )
 ]
)

pipeline {
    agent any
    environment {
     KCLI_CONFIG = credentials("${params.kcli_config_yml}")
     KCLI_SSH_ID_RSA = credentials("${params.kcli_id_rsa}")
     KCLI_SSH_ID_RSA_PUB = credentials("${params.kcli_id_rsa_pub}")
     KCLI_PARAMETERS = "-P prefix=${params.prefix} -P image=${params.image} -P pool=${params.pool} -P network=${params.network} -P vms=${params.vms}"
     CONTAINER_OPTIONS = "--net host --rm --security-opt label=disable -v $HOME/.kcli:/root/.kcli -v $PWD:/workdir -v /var/tmp:/ignitiondir"
     KCLI_CMD = "podman run ${CONTAINER_OPTIONS} karmab/kcli"
    }
    stages {
        stage('Prepare kcli environment') {
            steps {
                sh '''
                [ -d $HOME/.kcli ] && rm -rf $HOME/.kcli
                mkdir $HOME/.kcli
                cp "$KCLI_CONFIG" $HOME/.kcli/config.yml
                cp "$KCLI_SSH_ID_RSA" $HOME/.kcli/id_rsa
                chmod 600 $HOME/.kcli/id_rsa
                cp "$KCLI_SSH_ID_RSA_PUB" $HOME/.kcli/id_rsa.pub
                
                '''
            }
        }
        stage('Check kcli client') {
            steps {
                sh '${KCLI_CMD} list client'
            }
        }
        stage('Deploy kcli plan') {
            steps {
                script {
                  KCLI_CLIENT = ""
                  if ( "${params.kcli_client}" != "" ) {
                     KCLI_CLIENT = "-C ${params.kcli_client}"
                  }
                  if ( "${params.wait}" == "true" ) {
                     WAIT = "--wait"
                  } else {
                     WAIT = ""
                  }
                }
                sh """
                  ${KCLI_CMD} ${KCLI_CLIENT} create plan -f ${WORKSPACE}/kcli_plan.yml ${KCLI_PARAMETERS} ${WAIT} ${env.JOB_NAME}_${env.BUILD_NUMBER}
                """
            }
        }
    }
}
