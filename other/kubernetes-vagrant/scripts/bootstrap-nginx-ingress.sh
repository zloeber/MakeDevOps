#!/bin/sh
EXTERNALDNSNAME='k8s.zacharyloeber.com'
echo "Setting up an Nginx Ingress Controller.."
helm install --name=ingress stable/nginx-ingress --namespace ingress --set controller.hostNetwork=true,controller.kind=DaemonSet,rbac.create=true


cat > nginx-ingress.yaml <<EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: nginx-ingress
spec:
  rules:
  - host: ${EXTERNALDNSNAME}
    http:
      paths:
      - backend:
          serviceName: nginx-ingress
          servicePort: 18080
        path: /nginx_status
EOF
cat > app-ingress.yaml <<EOF
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
  name: app-ingress
spec:
  rules:
  - host: ${EXTERNALDNSNAME}
    http:
      paths:
      - backend:
          serviceName: appsvc1
          servicePort: 80
        path: /app1
      - backend:
          serviceName: appsvc2
          servicePort: 80
        path: /app2
EOF

kubectl create -f nginx-ingress.yaml -n=ingress
kubectl create -f app-ingress.yaml

cat > nginx-ingress-controller-service.yaml <<EOF
apiVersion: v1
kind: Service
metadata:
  name: nginx-ingress
spec:
  type: NodePort
  ports:
    - port: 80
      nodePort: 30000
      name: http
    - port: 18080
      nodePort: 32000
      name: http-mgmt
  selector:
    app: nginx-ingress-lb
EOF

kubectl create -f nginx-ingress-controller-service.yaml -n=ingress

#VBoxManage modifyvm "master" --natpf1 "nodeport,tcp,127.0.0.1,30000,,30000"
#VBoxManage modifyvm "master" --natpf1 "nodeport2,tcp,127.0.0.1,32000,,32000"