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

    $.getJSON('http://localhost:8000/last/' + getBlockParameter(), function (data) {
    //$.getJSON('http://data.blockframe.xyz:8000/last/' + getBlockParameter(), function (data) {

        datapoints =

            data.map(function(price)  {

            var datapoint;
            
            try {

                datapoint =  {

                    x: price['block height'],

                    y: [

                        price.open,
                        price.high,
                        price.low,
                        price.close

                    ],

                    //label: new Date(element.data.candle.mts).toLocaleDateString().toString() + ' - ' + element.height.toString()
                    label: price.height

                };

            }

            catch(exception) {

                console.error('Null datapoint for block ' + price.height)

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