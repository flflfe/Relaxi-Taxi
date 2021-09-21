import 'package:flutter/material.dart';
import 'package:clay_containers/clay_containers.dart';
import 'package:relaxi_driver/constants/all_cons.dart';
import 'package:google_fonts/google_fonts.dart';
class MapButton extends StatelessWidget {
  Icon icon;
  final VoidCallback onPressed;
  final String heroTag;
  MapButton({Key? key,required this.icon, required this.onPressed,required this.heroTag}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return ClayContainer(
      width: (50/xd_width)*_width,
      height: (50/xd_width)*_width,
      borderRadius: ((50/xd_width)*_width)/2,
      color: baseColor,
      spread: 5,
      child:  FloatingActionButton(
        heroTag: heroTag,
        onPressed: onPressed,
        child: icon,
        backgroundColor:baseColor,

      ),
    );
  }
}

class SubmitButton extends StatelessWidget {
  final String txt;
  final VoidCallback onPressed;
  const SubmitButton({Key? key, required this.onPressed,required this.txt}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double _height= MediaQuery.of(context).size.height;
    final double _width= MediaQuery.of(context).size.width;
    return DecoratedBox(
      decoration: BoxDecoration(
          gradient: LinearGradient(colors: [grad1, grad1,grad2],end:Alignment.topCenter,begin:Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(50),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: grey.withOpacity(0.5),
                blurRadius: 1,
                spreadRadius: 0,
                offset: Offset(1.0,0)
            ),
            BoxShadow(
                color: grey.withOpacity(0.5),
                blurRadius: 2,
                spreadRadius: 0,
                offset: Offset(-1.0,1.0)
            ),

          ]
      ),
      child: ElevatedButton(
        onPressed:onPressed,
        style:ElevatedButton.styleFrom(
          fixedSize:Size(((250/xd_width)*_width),((61/xd_height)*_height)),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40)),
          primary: Colors.transparent,
          onPrimary: Colors.white,
          shadowColor: Colors.transparent,
          onSurface: yellow,


        ),
        child: Text(txt,style: GoogleFonts.montserrat(textStyle: TextStyle(fontSize: 20.0, ),fontWeight: FontWeight.w600),
          textAlign: TextAlign.center,),),
    );
  }
}
