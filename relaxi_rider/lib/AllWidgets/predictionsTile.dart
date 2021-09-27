import 'package:flutter/material.dart';
import 'package:flutter_app/AllScreens/RegistrationScreen.dart';
import 'package:flutter_app/Models/placePredictions.dart';
import 'package:flutter_app/constants/all_cons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_app/AllScreens/searchScreen.dart' as search;
class PredictionsTile extends StatelessWidget {
  final PlacePredictions placePredictions;
  final String location;
  const PredictionsTile({Key? key, required this.placePredictions, required this.location}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: TextButton(
        onPressed: (){
        search.getPlaceAddressDetails(placePredictions.place_id, context, place: location);
        },
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered))
                return Colors.orangeAccent.withOpacity(0.1);
              if (states.contains(MaterialState.focused) ||
                  states.contains(MaterialState.pressed))
                return grad1.withOpacity(0.1);
              return Colors.red; // Defer to the widget's default.
            },
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Icon(Icons.add_location_alt_outlined, color: grad1,),
              SizedBox(width: 15.0,),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(placePredictions.main_text,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.overlock(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87
                        ),
                    ),
                    SizedBox(height: 1,),
                    Text(placePredictions.secondary_text,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.overlock(
                          fontSize: 14,
                          color: Colors.grey[500]
                      ),)
                  ],
                ),
              )
            ],

          ),
        ),
      ),
    );
  }
}
