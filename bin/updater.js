#!/usr/bin/env node

var TIME = 300000

var wsdeploy = true

import { execSync as $ } from 'child_process'
import WebSocket from 'ws';

function loop() {
  console.log('deploying', process.cwd())
  var out = $('./bin/deploy.sh')
  console.log('out', out)
}

loop()
setInterval(loop, TIME)


if (wsdeploy) {


  const ws = new WebSocket('ws://gitmark.me:4444');

  ws.on('open', function open() {
    console.log('opened')

    var lastCommit = $('./bin/gitmark.sh').toString()
    console.log('lastCommit', lastCommit)
    lastCommit?.replace(' ', ':')

    ws.send('sub ' + lastCommit + ':0')
  });


  ws.on('message', function incoming(message) {
    console.log('received: %s', message);
    // todo if pub run loop
  });


}