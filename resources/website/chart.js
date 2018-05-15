var datapoints;

function getBlockParameter() {

    var url = window.location.href;
    var blocks;

    if (url.indexOf('blocks') != -1) {

        blocks = url.substr(url.indexOf('blocks=') + 'blocks='.length, url.length);

    }

    else {

        blocks = 100;

    }

    return blocks;

}

window.onload = function () {

    $.getJSON('http://data.blockframe.xyz:8000/last/' + getBlockParameter(), function (data) {

        datapoints =

            data.map(function(block)  {

            var datapoint;
            
            try {

                datapoint =  {

                    x: block.height,

                    y: [

                        block.price.candle.open,
                        block.price.candle.high,
                        block.price.candle.low,
                        block.price.candle.close

                    ],

                    //label: new Date(element.data.candle.mts).toLocaleDateString().toString() + ' - ' + element.height.toString()
                    label: block.height

                };

            }

            catch(exception) {

                console.error('Null datapoint for block ' + block.height)

            }

            finally {

                return datapoint;

            }

        });

        var chart = new CanvasJS.Chart("chartContainer",
            {
                /*title: {
                    text: "Price X Blockframe Height "
                },*/
                zoomEnabled: true,
                axisY: {
                    includeZero: false,
                    //title: "Prices",
                    prefix: "$ "
                },
                axisX: {
                    interval: 2,
                    intervalType: "number",
                    //valueFormatString: "MMM-YY",
                    //title: "Block Height",
                    labelAngle: -45,
                    labelFontSize: 11
                },
                data: [
                    {
                        type: "candlestick",
                        risingColor: "#F79B8E",
                        dataPoints: datapoints

                    }
                ]
            });
        chart.render();
    })
};