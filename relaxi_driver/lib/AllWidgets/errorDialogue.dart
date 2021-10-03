import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ErrorDialogue extends StatelessWidget {
  final String message;
  const ErrorDialogue({Key? key,required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return AlertDialog(
      title: Image.asset('assets/error_auth.png',),
      elevation: 5.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0)
      ),
      contentPadding: EdgeInsets.all(5),
      content: Text(message,textAlign: TextAlign.center,style: GoogleFonts.montserrat(
          fontSize: 16.0
      ),),
      actions: [
        Center(
          child: ElevatedButton(onPressed: (){
            Navigator.pop(context);
          },
              child: Text('got it!', style: GoogleFonts.montserrat(
                color: Colors.white
              ),),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.red)
          ),
          ),
        )
      ],
    );
  }
}
