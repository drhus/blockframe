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

                    label: 'Block ' + price['block height'] + ' @ ' + new Date(price.mts).toISOString()
                    //label: price.height0

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
                ],
                options: {
                    scales: {
                        xAxes: [{
                            ticks: {
                                beginAtZero:true,
                                callback: function(value, index, values) {
                                    return '$ ' + number_format(value);
                                }
                            }
                        }]
                    },
                    tooltips: {
                        callbacks: {
                            label: function(tooltipItem, chart){
                                var datasetLabel = chart.datasets[tooltipItem.datasetIndex].label || '';
                                return datasetLabel + ': $ ' + number_format(tooltipItem.yLabel, 2);
                            }
                        }
                    }
                }
            });
        chart.render();
    })
};