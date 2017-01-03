var i = 1;
console.log('Meteor Run Time');
(function wait () {
    process.stdout.write('Uptime: ' + i + 's\r');
   if (true) {
       setTimeout(wait, 1000);
       i++;
   }
})();