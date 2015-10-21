#!/usr/bin/env bash
ssh yuri -C "echo $(dig +short myip.opendns.com @resolver1.opendns.com) > /tmp/ipfegreac.txt"
