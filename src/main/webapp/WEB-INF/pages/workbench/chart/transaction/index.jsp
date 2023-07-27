
<!DOCTYPE html>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String basePath = request.getScheme() + "://" +
            request.getServerName() + ":" + request.getServerPort() +
            request.getContextPath() + "/";
%>
<html>
<head>
    <base href="<%=basePath%>">
    <meta charset="UTF-8">
    <link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <script type="text/javascript" src="jquery/echars/echarts.min.js"></script>
    <script type="text/javascript">
        $(function (){
            $.ajax({
                url:'workbench/transaction/queryTranStage.do',
                type:'post',
                dataType:'json',
                success:function (data){
                    // 基于准备好的dom，初始化echarts实例
                    var myChart = echarts.init(document.getElementById('main'));
                    // 使用刚指定的配置项和数据显示图表。
                    myChart.setOption({
                        title: {
                            text: '交易统计图表',
                            subtext:'交易表中各个阶段的数量'
                        },
                        tooltip: {
                            trigger: 'item',
                            formatter: '{a} <br/>{b} : {c}'
                        },
                        toolbox: {
                            feature: {
                                dataView: { readOnly: false },
                                restore: {},
                                saveAsImage: {}
                            }
                        },
                        legend: {
                            data: data.name
                        },
                        series: [
                            {
                                name: '数据量',
                                type: 'funnel',
                                left: '10%',
                                top: 60,
                                bottom: 60,
                                width: '80%',
                                min: 0,
                                max: 100,
                                minSize: '0%',
                                maxSize: '100%',
                                sort: 'descending',
                                gap: 2,
                                label: {
                                    formatter:'{b}'

                                },
                                labelLine: {
                                    show:true,
                                    length: 10,
                                    lineStyle: {
                                        width: 1,
                                        type: 'solid'
                                    }
                                },
                                itemStyle: {
                                    opacity:0.7,
                                    borderColor: '#fff',
                                    borderWidth: 1
                                },
                                emphasis: {
                                    label: {
                                        fontSize: 20,
                                        position:'inside',
                                        formatter:'{b}:{c}'
                                    }
                                },
                                data:  data.nameValue
                            }
                        ]
                    });
                }
            });

        })
    </script>
</head>
<body>
<!-- 为 ECharts 准备一个定义了宽高的 DOM -->
<div id="main" style="left:10%;width: 1200px;height:500px;"></div>
</body>
</html>
