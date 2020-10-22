load sugar
m = parafac(sugar,3,struct('plots','off'));
A = m.loads{1};
A = [ones(size(A,1),1) A];
b = pinv(A(1:40,:))*Color(1:40);
yp = A*b;

Xnoc = [Color(1:40) yp(1:40)];

id = [1:80];
Xnoc_test = [Color(id) yp(id)];