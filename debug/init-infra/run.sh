# clone code
git clone git@github.com:jinbangyi/gitops.git
cd gitops/cluster/init
# apply argocd
kubectl kustomize argocd | kubectl apply -f -
# apply local storage
kubectl kustomize storage/ | kubectl apply -f -
# apply application
kubectl apply -f manifest/


# Generate private key
openssl genpkey -algorithm RSA -out ca.key

# Generate self-signed CA certificate
openssl req -x509 -new -nodes -key ca.key -sha256 -days 365 -out ca.crt -subj "/CN=self-signed-CA"
