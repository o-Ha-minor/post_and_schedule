const { environment } = require('@rails/webpacker')
environment.config.merge({
    node: {
      global: true,
      __dirname: false,
      __filename: false,
    }
  })
  
module.exports = environment
