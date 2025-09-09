# 🏛️ Cultural Heritage NFT Registry

A Clarity smart contract for digitally preserving cultural heritage items and oral traditions as NFTs with comprehensive provenance tracking.

## 🌟 Features

- **🎨 Heritage NFT Minting**: Create unique NFTs for cultural heritage items
- **📜 Provenance Tracking**: Complete ownership and transaction history
- **✅ Verification System**: Authorized verifiers can validate heritage items
- **🔄 Metadata Updates**: Creators can update heritage item information
- **🛡️ Secure Transfers**: Built-in transfer functionality with history tracking
- **👥 Authorization Management**: Contract owner can manage verifiers

## 📋 Contract Structure

### Heritage Item Properties
- Name and description
- Cultural origin and significance
- Heritage type classification
- Creation timestamp
- Creator identity
- Verification status

### Provenance History
- Complete ownership chain
- Transaction timestamps
- Transaction types (mint, transfer)

## 🚀 Usage

### Minting Heritage NFTs

```clarity
(contract-call? .Cultural-Heritage-NFT-Registry mint-heritage-nft
  "Ancient Scroll"
  "A 500-year-old manuscript containing traditional stories"
  "Maya Civilization"
  "Represents oral traditions passed down through generations"
  "Document"
  'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
```

### Transferring NFTs

```clarity
(contract-call? .Cultural-Heritage-NFT-Registry transfer
  u1
  tx-sender
  'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
```

### Verifying Heritage Items

```clarity
(contract-call? .Cultural-Heritage-NFT-Registry verify-heritage-item u1)
```

### Querying Heritage Items

```clarity
(contract-call? .Cultural-Heritage-NFT-Registry get-heritage-item u1)
(contract-call? .Cultural-Heritage-NFT-Registry get-provenance-history u1)
(contract-call? .Cultural-Heritage-NFT-Registry get-owner u1)
```

## 👨‍💼 Admin Functions

### Add Authorized Verifier
```clarity
(contract-call? .Cultural-Heritage-NFT-Registry add-authorized-verifier
  'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
```

### Remove Authorized Verifier
```clarity
(contract-call? .Cultural-Heritage-NFT-Registry remove-authorized-verifier
  'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
```

### Transfer Contract Ownership
```clarity
(contract-call? .Cultural-Heritage-NFT-Registry transfer-ownership
  'ST2CY5V39NHDPWSXMW9QDT3HC3GD6Q6XX4CFRK9AG)
```

## 🔧 Development

### Prerequisites
- Clarinet CLI installed
- Stacks wallet for testing

### Testing
```bash
clarinet test
```

### Deploy
```bash
clarinet deploy
```

## 🎯 Use Cases

- **🏛️ Museums**: Digitize and track cultural artifacts
- **📚 Libraries**: Preserve rare manuscripts and documents
- **🎭 Cultural Organizations**: Document traditional practices
- **🎨 Artists**: Protect intellectual property of cultural works
- **🏫 Educational Institutions**: Create verified cultural archives

## 📄 Contract Functions

### Read-Only Functions
- `get-contract-owner()` - Get current contract owner
- `get-last-token-id()` - Get the latest minted token ID
- `get-heritage-item(token-id)` - Get heritage item details
- `get-provenance-history(token-id)` - Get complete ownership history
- `get-owner(token-id)` - Get current NFT owner
- `is-authorized-verifier(verifier)` - Check verifier authorization

### Public Functions
- `mint-heritage-nft(...)` - Mint new heritage NFT
- `transfer(token-id, sender, recipient)` - Transfer NFT ownership
- `verify-heritage-item(token-id)` - Verify heritage item authenticity
- `update-heritage-metadata(...)` - Update item metadata
- `add-authorized-verifier(verifier)` - Add new verifier (owner only)
- `remove-authorized-verifier(verifier)` - Remove verifier (owner only)
- `transfer-ownership(new-owner)` - Transfer contract ownership

## 🛡️ Security Features

- Owner-only administrative functions
- Input validation for all parameters
- Secure NFT transfer mechanism
- Authorized verifier system
- Comprehensive error handling

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📜 License

This project is open source and available under the MIT License.

---

*Preserving cultural heritage for future generations through blockchain technology* 🌍✨
