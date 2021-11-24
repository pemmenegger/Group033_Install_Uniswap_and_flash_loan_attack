module.exports = {
      /* ... rest of truffle-config */
	compilers: {
     solc: {
       version: '0.5.16', // ex:  "0.4.20". (Default: Truffle's installed solc)
     settings: {
        optimizer: {
          enabled: true,
          runs: 1500
        }
      }
}
  },
      plugins: [
        'truffle-contract-size'
      ]
    }
