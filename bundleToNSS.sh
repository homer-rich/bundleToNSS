#!/bin/bash
# Author: Homer Rich
# Use: Convert P7 bundle from cyber.mil and load it into an NSS database.

if [[ $1 = "help" ]] || [[ $1 = "-h" ]] || [[ $1 = "--help" ]] || [[ -z $1 ]]; then
  printf "###############################################################################\n"
  printf "Run this command to add all certs in a PKCS7(P7) bundle to your NSS store\n"
  printf "Dependencies: nss openssl awk sed grep\n"
  printf "Arguments: 1:Pem that you would like loaded.  2:NSS location to load in to.\n"
  printf "Example usage:\n"
  printf "\t$ bash bundleToNSS.sh Certificates_PKCS7_v5.5_DOD.pem.p7b ~/alias/nssdb\n" 
  printf "###############################################################################\n"
  exit 0
fi
inputCertChain=$(openssl pkcs7 -in $1 -print_certs)
subjectCount=$(echo "$inputCertChain" | grep "subject" | wc -l)
touch tempCer
if [[ $? -eq 0 ]]; then
  for (( i=1 ; i < "$subjectCount" ; i++ )); do
    curPem=$(echo "$inputCertChain" | awk  "/subject=/{n++};n==$i;n==$i+1{exit}")
    curSubject=$(echo "$curPem" | head -1 | sed "s/.*=//g")
    #printf "\n$curSubject"
    curCert=$(echo "$curPem" | awk "NR>2")
    #printf "\n$curCert"
    echo "$curCert" > tempCer
    echo "Writing $curSubject into NSS database."
    certutil -A -d $2 -n "$curSubject" -t "CT,C,C" -i tempCer
  done
  rm tempCer
else
  echo "User does not have permission in this folder.  Try again"
  exit 1
fi
