#!/bin/bash
cp private.key ~/.ssh/
cp public.pub ~/.ssh/
touch ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
cat public.pub >> ~/.ssh/authorized_keys
ssh-keygen -f  acit4050 -P "admin"
cp acit4050  ~/.ssh/
cp acit4050.pub  ~/.ssh/
cat acit4050.pub >> ~/.ssh/authorized_keys
