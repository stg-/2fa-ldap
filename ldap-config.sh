#!/bin/bash

if [ -z ${LDAP_BASE} ] || [ -z ${LDAP_HOSTNAME} ] || [ -z ${LDAP_PORT} ]|| [ -z ${LDAP_BINDDN} ] || [ -z ${LDAP_BINDPW} ];then
  echo "File libnss-ldap.conf could not be created."
  exit 1;
fi

cat << EOF > /etc/ssh/fetchSSHKeysFromLDAP.sh
#!/bin/bash

ldapsearch -h ${LDAP_HOSTNAME} -p ${LDAP_PORT} -x -b '${LDAP_BASE}' \
    '(&(objectClass=ldapPublicKey)(uid='"\$1"'))' 'sshPublicKey' | \
    sed -n '/^ /{H;d};/sshPublicKey:/x;\$g;s/\n *//g;s/sshPublicKey: //gp'

EOF

chmod 700 /etc/ssh/fetchSSHKeysFromLDAP.sh

cat << EOF > /etc/libnss-ldap.conf
base ${LDAP_BASE}
uri ldap://${LDAP_HOSTNAME}:${LDAP_PORT}/
ldap_version 3
binddn ${LDAP_BINDDN}
bindpw ${LDAP_BINDPW}
EOF

echo "File libnss-ldap.conf created successfully."

service nscd start

exit 0

