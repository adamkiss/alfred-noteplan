module.exports = (items, close = true) => {
    console.log(JSON.stringify({items}));
    
    if (close) process.exit();
}