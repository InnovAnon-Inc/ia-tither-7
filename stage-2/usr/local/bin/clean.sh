#! /bin/bash
(( ! UID ))
(( ! $#  ))

apt autoremove
apt clean
rm -rf /tmp/*                                  \
       /var/log/alternatives.log               \
       /var/log/apt/history.log                \
       /var/lib/apt/lists/*                    \
       /var/log/apt/term.log                   \
       /var/log/dpkg.log                       \
       /var/tmp/*

