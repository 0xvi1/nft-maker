// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import { Base64 } from "./libraries/Base64.sol";

// Our contact inherits ERC721URIStorage, so we'll have access to the inherited contract's methods.
contract NFT is ERC721URIStorage {
	using Counters for Counters.Counter;
	Counters.Counter private _tokenIdIndex;

	// SVG code. All we need to change is the word that's displayed. Everything else stays the same.
	// So, we make a svg variables here that all our NFTs can use.
	string svgPartOne =
		"<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='";
	string svgPartTwo =
		"'/><text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>";

	// I create three arrays, each with their own theme of random words.
	// Pick some random funny words, names of anime characters, foods you like, whatever!
	string[] firstWords = [
		"Superman",
		"Ninja",
		"Pirate",
		"Ironman",
		"Batman",
		"Wonderwoman"
	];
	string[] secondWords = [
		"Coffee",
		"Tea",
		"Milk",
		"Whiskey",
		"Beer",
		"Vodka"
	];
	string[] thirdWords = [
		"Italy",
		"France",
		"England",
		"Mexico",
		"Sweden",
		"Germany"
	];

	string[] colors = [
		"red",
		"#08C2A8",
		"black",
		"yellow",
		"blue",
		"green"
	];

	event NewNFTMinted(
		address sender,
		uint256 tokenId
	);

	// I create a function to randomly pick a word from each array.
	function pickRandomFirstWord(
		uint256 tokenId
	) public view returns (string memory) {
		// Seed the random generator.
		uint256 rand = random(
				string(
					abi
						.encodePacked(
							"FIRST_WORD",
							Strings
								.toString(
									tokenId
								)
						)
				)
			);
		// Squash the # between 0 and the length of the array to avoid going out of bounds.
		rand =
			rand %
			firstWords
				.length;
		return
			firstWords[
				rand
			];
	}

	function pickRandomSecondWord(
		uint256 tokenId
	) public view returns (string memory) {
		uint256 rand = random(
				string(
					abi
						.encodePacked(
							"SECOND_WORD",
							Strings
								.toString(
									tokenId
								)
						)
				)
			);
		rand =
			rand %
			secondWords
				.length;
		return
			secondWords[
				rand
			];
	}

	function pickRandomThirdWord(
		uint256 tokenId
	) public view returns (string memory) {
		uint256 rand = random(
				string(
					abi
						.encodePacked(
							"THIRD_WORD",
							Strings
								.toString(
									tokenId
								)
						)
				)
			);
		rand =
			rand %
			thirdWords
				.length;
		return
			thirdWords[
				rand
			];
	}

	function pickRandomColor(
		uint256 tokenId
	) public view returns (string memory) {
		uint256 rand = random(
				string(
					abi
						.encodePacked(
							"COLOR",
							Strings
								.toString(
									tokenId
								)
						)
				)
			);
		rand =
			rand %
			colors
				.length;
		return
			colors[
				rand
			];
	}

	function random(string memory input)
		internal
		pure
		returns (
			uint256
		)
	{
		return
			uint256(
				keccak256(
					abi
						.encodePacked(
							input
						)
				)
			);
	}

	// Pass the NFTs "token name" and it's "symbol".
	// token name = PulpFictionNFT
	// symbol = PULP
	constructor()
		ERC721(
			"PulpFictionNFT",
			"PULP"
		)
	{
		console
			.log(
				"Inside NFT contract constructor"
			);
	}

	// A function our user will call to get their NFT.
	function makeAnNFT() public {
		// Get the current tokenId, this starts at 0.
		uint256 currentTokenId = _tokenIdIndex
				.current();

		// Randomly grab one word from each of the three arrays.
		string
			memory first = pickRandomFirstWord(
				currentTokenId
			);
		string
			memory second = pickRandomSecondWord(
				currentTokenId
			);
		string
			memory third = pickRandomThirdWord(
				currentTokenId
			);
		string
			memory combinedWord = string(
				abi
					.encodePacked(
						first,
						second,
						third
					)
			);

		string
			memory randomColor = pickRandomColor(
				currentTokenId
			);

		// Concatenate it all together, and then close the <text> and <svg> tags.
		string
			memory finalSvg = string(
				abi
					.encodePacked(
						svgPartOne,
						randomColor,
						svgPartTwo,
						combinedWord,
						"</text></svg>"
					)
			);

		// Get all the JSON metadata in place and base64 encode it.
		// - Set the title of NFT as the generated word.
		// - Set the description
		// - Set the image as data:image/svg+xml;base64+<base64 encoded finalSvg>
		string
			memory base64EncodedFinalSvg = Base64
				.encode(
					bytes(
						finalSvg
					)
				);
		string
			memory imageDataAsJSON = Base64
				.encode(
					bytes(
						string(
							abi
								.encodePacked(
									'{"name": "',
									combinedWord,
									'", "description": "A highly acclaimed collection of squares.", "image": "data:image/svg+xml;base64,',
									base64EncodedFinalSvg,
									'"}'
								)
						)
					)
				);

		// Prepend data:application/json;base64, to our data.
		string
			memory finalTokenUri = string(
				abi
					.encodePacked(
						"data:application/json;base64,",
						imageDataAsJSON
					)
			);

		console
			.log(
				"\n--------------------"
			);
		console
			.log(
				string(
					abi
						.encodePacked(
							"https://nftpreview.0xdev.codes/?code=",
							finalTokenUri
						)
				)
			);
		console
			.log(
				"--------------------\n"
			);

		// _safeMint mints the NFT with id = currentTokenId to the sender.
		_safeMint(
			msg
				.sender,
			currentTokenId
		);

		// Set the NFTs data.
		_setTokenURI(
			currentTokenId,
			finalTokenUri
		);

		// Increment the counter for when the next NFT is minted.
		_tokenIdIndex
			.increment();

		console
			.log(
				"An NFT w/ ID %s has been minted by %s",
				currentTokenId,
				msg
					.sender
			);

		emit NewNFTMinted(
			msg
				.sender,
			currentTokenId
		);
	}
}
