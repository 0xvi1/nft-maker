async function main() {
  var provider = await hre.ethers.providers.getDefaultProvider();

  await provider
    .getTransactionReceipt(
      "0x158e85ab66a9f33b16ead3bb83b86b43d51320e24081679f6cbe34b2f925f972"
    )
    .then(function (receipt) {
      console.log(receipt);
    });

  var transactionHash =
    "0x158e85ab66a9f33b16ead3bb83b86b43d51320e24081679f6cbe34b2f925f972";

  provider.getTransaction(transactionHash).then(function (transaction) {
    console.log(transaction);
  });

  provider
    .getTransactionReceipt(transactionHash)
    .then(function (transactionReceipt) {
      console.log(transactionReceipt);
    });
}

main();
