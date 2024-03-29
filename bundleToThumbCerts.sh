#!/bin/bash
# Author: Homer Rich
# Use: Convert P7 bundle from cyber.mil and dump the files locally.

if [[ $1 = "help" ]] || [[ $1 = "-h" ]] || [[ $1 = "--help" ]] || [[ -z $1 ]]; then
  printf "###############################################################################\n"
  printf "Run this command to dump all certs in a PKCS7(P7) bundle to your local directory\n"
  printf "Dependencies: nss openssl awk sed grep\n"
  printf "Arguments: 1:Pem Bundle that you would like dumped."
  printf "Example usage:\n"
  printf "\t$ bash bundleToThumbCerts.sh Certificates_PKCS7_v5.5_DOD.pem.p7b\n" 
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
    curThumbSHA1=$(openssl x509 -fingerprint -in tempCer -noout | sed "s/.*=//g" | sed "s/://g")
    openssl x509 -in tempCer -out $curThumbSHA1.pem
  done
  rm tempCer
else
  echo "User does not have permission in this folder.  Try again"
  exit 1
fi
