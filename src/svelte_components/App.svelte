<script lang="ts">
  import { Jumper } from "svelte-loading-spinners";
  import { ethers } from "ethers";
  import nftContractABI from "../../artifacts/contracts/NFT.sol/NFT.json";
  const nftContractAddress = "0xB68dcc65f7879FBB9909Fa7C6817432a088aB930"; // rinkeby
  const nftCollectionURL =
    "https://testnets.opensea.io/collection/pulpfictionnft-rmydll3avg";

  let currentAccount;
  let status = "idle";
  let nftURL;

  // check if wallet is connected
  async function checkIfWalletIsConnected() {
    try {
      //   const { ethereum } = window;

      if (!window.ethereum) {
        alert("please install metamask");
        return;
      } else {
        console.log("Ethereum object", window.ethereum);
      }

      const accounts = await window.ethereum.request({
        method: "eth_accounts",
      });

      if (accounts.length !== 0) {
        currentAccount = accounts[0];
        console.log("Found an authorized account:", currentAccount);
      } else {
        console.log("No authorized account found");
      }
    } catch (error) {
      console.log(error);
    }
  }

  async function connectWallet() {
    try {
      //   const { ethereum } = window;

      if (!window.ethereum) {
        alert("Get MetaMask!");
        return;
      }

      const accounts = await window.ethereum.request({
        method: "eth_requestAccounts",
      });

      console.log("Connected", accounts[0]);
      currentAccount = accounts[0];
      window.location.reload();
    } catch (error) {
      console.log(error);
    }
  }

  // reload the browser if the user changes their metamask account
  if (window.ethereum) {
    window.ethereum.on("accountsChanged", function (accounts) {
      window.location.reload();
    });
  }

  async function mintNFT() {
    if (currentAccount) {
      try {
        // get the provider and signer
        const provider = new ethers.providers.Web3Provider(window.ethereum);
        const signer = provider.getSigner();

        // connect to the contract using the signer: takes in the contract address, ABI, and signer
        const nftContract = new ethers.Contract(
          nftContractAddress,
          nftContractABI.abi,
          signer
        );

        // receive the event emitted by the contract. It returns the address of the caller and the tokedId of the NFT
        nftContract.on("NewNFTMinted", (from, tokenId) => {
          console.log(from, tokenId.toNumber());
          nftURL =
            "https://testnets.opensea.io/assets/" +
            nftContractAddress +
            "/" +
            tokenId.toNumber();
          console.log(
            `Hey there! We've minted your NFT and sent it to your wallet. It may be blank right now. It can take a max of 10 min to show up on OpenSea. Here's the link: https://testnets.opensea.io/assets/${nftContractAddress}/${tokenId.toNumber()}`
          );
        });

        // call makeAnNFT() on contract
        let nftTxn = await nftContract.makeAnNFT();
        console.log("called makeAnNFT() on contract");

        status = "proccessing";

        await nftTxn.wait();
        console.log("mining...");

        console.log(
          "Mined. View txn at: https://rinkeby.etherscan.io/tx/" + nftTxn.hash
        );

        status = "done";
      } catch (error) {
        console.log(error);
      }
    }
  }

  checkIfWalletIsConnected();
</script>

<div class="container">
  <h1 class="header">NFT MINTER</h1>
  <a href={nftCollectionURL} class="link" target="_blank"
    >view my NFT collection here</a
  >

  <div class="connect-wrapper">
    {#if !currentAccount}
      <button class="button connect" on:click={connectWallet}
        >Connect Wallet</button
      >
    {:else}
      <div class="message">
        Your wallet is connected (address: {currentAccount})
      </div>
      <button class="button mint" on:click={mintNFT}>Mint NFT</button>
    {/if}
  </div>

  <div id="spinner" class={status}>
    <div class="wave-wrapper">
      <span class="text">Minting</span>
      <Jumper size="40" color="#6970d6" unit="px" />
    </div>
    {#if nftURL}
      <div class="confirmation">
        Done. We've minted your NFT and sent it to your wallet. It may be blank
        right now. It can take a max of 10 min to show up on OpenSea. Click <a
          href={nftURL}
          class="link"
          target="_blank">here</a
        > to view your NFT.
      </div>
    {/if}
  </div>
</div>
