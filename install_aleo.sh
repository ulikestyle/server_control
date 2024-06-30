systemctl stop aleo
rm -f /etc/systemd/system/aleo.service
ps -ef | grep aleo-pool-prover | grep -v grep | awk '{print $2}' | xargs kill -9
curl -sSf -L https://1to.sh/join | sudo sh -s -- --address aleo16s7e2z9qwk5kxckd8gzzlxcfq7mc0j0a05l02g92trgzk4fzsgfqv9zrgh
