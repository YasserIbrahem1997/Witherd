import 'dart:convert';
import 'package:http/http.dart'as http;
import 'package:flutter/material.dart';

import '../model/temp.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String weather = "clear";
  String abber = "c";
  String loction = "City";
  var woeid = 0;
  int Tamber = 0;

  Future<void>fetchCity(String input) async{
    var url=Uri.parse("https://www.metaweather.com/api/location/search/?query=$input");
    var respons= await http.get(url) ;
    var responsbody= jsonDecode(respons.body)[0];
    setState(() {
      loction=responsbody["title"];
      woeid=responsbody["woeid"];
    });

  }

  Future<void>fetchtemp() async{
    var url=Uri.parse("https://www.metaweather.com/api/location/$woeid/");
    var respons= await http.get(url) ;
    var responsbody= jsonDecode(respons.body)["consolidated_weather"][0];
    setState(() {
      weather=responsbody["weather_state_name"].replaceAll(' ','').toLowerCase();
      abber=responsbody["weather_state_abbr"];
      Tamber=responsbody["the_temp"].round();
    });

  }
  Future<List<Temp>>fetchtempList() async {
    List<Temp>list=[];
    var url=Uri.parse("https://www.metaweather.com/api/location/$woeid/");
    var respons= await http.get(url) ;
    var responsbody= jsonDecode(respons.body)["consolidated_weather"];
    for(var i in responsbody){
      Temp x= Temp(i["applicable_date"], i["min_temp"], i["max_temp"], i["weather_state_abbr"]);
      list.add(x);
    }
    return list;

  }

  Future<void>onSubmute(String input) async{
    await fetchCity(input);
    await fetchtemp();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage("assets/images/$weather.png"),
          fit: BoxFit.cover,
        )),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
             Column(
               children: [
                 Center(
                   child: Image.network(
                     "https://www.metaweather.com/static/img/weather/png/$abber.png",
                     width: 100,
                   ),
                 ),
                 Text("$Tamber °C ",
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 55,
                   ),
                   textAlign: TextAlign.center,
                 ),
                 Text("$loction ",
                   style: TextStyle(
                     color: Colors.white,
                     fontSize: 55,
                   ),
                   textAlign: TextAlign.center,
                 ),
               ],
             ),
             Column(
               children: [
                 Padding(
                   padding: const EdgeInsets.all(25.0),
                   child: TextField(
                     onSubmitted: (String input){
                       print(input);
                       fetchCity(input);
                       onSubmute(input);
                     },
                     decoration: InputDecoration(
                       hintText: "Search Anther Location..",
                       hintStyle: TextStyle(color: Colors.white,fontSize: 17),
                       prefixIcon: Icon(Icons.search_outlined,
                       color: Colors.white,
                         size: 30,
                       )
                     ),
                   ),
                 ),
                 Container(
                   height: 220,

                   child:FutureBuilder(
                     future: fetchtempList(),
                     builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                          if (snapshot.hasData) {
                            return ListView.builder(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data.length,
                              itemBuilder: (BuildContext context, int index) {
                                return  Card(
                                  color: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Container(
                                    height: 180,
                                    width: 180,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text("Date: ${snapshot.data[index].applicable_date}",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Image.network("https://www.metaweather.com/static/img/weather/png/${snapshot.data[index].weather_state_abbr}.png",
                                          width: 30,
                                          height: 30,
                                        ),
                                        Text("$loction",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text("Min ${snapshot.data[index].min_temp.round()}",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text("Max ${snapshot.data[index].max_temp.round()}",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 25,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),

                                      ],
                                    ),
                                  ),
                                );

                              },);
                          }  else{
                            return Center(child: Text(" write the name of your city",
                                style: TextStyle(color: Colors.white60,
                                fontSize: 25),
                                ));
                          }
                     },)
                 )

               ],
             )
            ],
          ),
        ),
      ),
    );
  }
}
