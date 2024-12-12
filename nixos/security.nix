{ secrets, ... }:
{

  security.pki.certificates = [
    (builtins.readFile "${secrets}/qfnit9nf285kekl4-myfritz-net.pem")
    (builtins.readFile "${secrets}/qfnit9nf285kekl4-myfritz-net-chain.pem")
  ];
}
