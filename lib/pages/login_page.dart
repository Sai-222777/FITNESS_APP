import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitness/components/my_text_field.dart';
import 'package:fitness/pages/home_page.dart';
import 'package:fitness/services/storage_service.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  final _auth2 = FirebaseAuth.instance;
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String selectedGender = '';
  final CollectionReference bioCollection = FirebaseFirestore.instance.collection('bio');
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    prevUserLogin();
  }

  @override
  void dispose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void prevUserLogin() async {
    String? email = await StorageService.getEmail();
    String? password = await StorageService.getPassword();
    if(email != null && password != null)
    {
      await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
    }
  }

  Future<void> signIn() async{
    if (loginEmailController.text.isEmpty || loginPasswordController.text.isEmpty){
      return;
    }
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: loginEmailController.text,
        password: loginPasswordController.text,
      );
      User? user = userCredential.user;
      if(user != null && user.emailVerified){
        await StorageService.storeEmail(loginEmailController.text);
        await StorageService.storePassword(loginPasswordController.text);
        await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomePage()),
          (Route<dynamic> route) => false,
        );
      }
      else
      {
        showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF8B0000),
                    Colors.black,
                    Color(0xFF8B0000),
                    ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ERROR',
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                        ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Email is not verified yet!',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.grey[800],fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF8B0000),
                  Colors.black,
                  Color(0xFF8B0000),
                  ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'ERROR',
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 20,
                      fontWeight: FontWeight.bold
                      ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Incorrect Username or Password',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Close',
                      style: TextStyle(color: Colors.grey[800],fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  Future<void> signUp() async{
    if(registerEmailController.text.isEmpty | registerPasswordController.text.isEmpty | selectedGender.isEmpty)
    {
      return;
    }
    if(registerPasswordController.text != confirmPasswordController.text)
    {
      await showDialog(
          context: context,
          builder: (ctx) => Dialog(
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF8B0000),
                    Colors.black,
                    Color(0xFF8B0000),
                    ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Error',
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                        ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Passwords do not match!',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(color: Colors.grey[800],fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        return ;
    }
    try {
        UserCredential userCredential =  await _auth2.createUserWithEmailAndPassword(
          email: registerEmailController.text,
          password: registerPasswordController.text,
        );
        DateTime now = DateTime.now();
        String username = registerEmailController.text.split('@')[0];
        if(username.length > 10)
        {
          username = username.substring(0,10);
        }
        await bioCollection.doc(registerEmailController.text).set(
          {
            'Gender':selectedGender,
            'Username':username.toUpperCase(),
            'ABS': '',
            'LEGS': '',
            'CHEST':'',
            'SHOULDERS & BACK' :'',
            'YOGA': '',
            'ARMS': '',
            'cm': '',
            'ft':'',
            'kg': '',
            'pd':'',
            'totalTime' : '0:0',
            'calories': 0,
            'startDate': '${now.year}-${now.month}-${now.day}',
            'level':1,
            'exp':0,
          }
          );
        loginEmailController.text = registerEmailController.text;
        loginPasswordController.text = registerPasswordController.text;
        User? user = userCredential.user;
        if(user != null && !user.emailVerified){
          await user.sendEmailVerification();
          await showDialog(
            context: context,
            builder: (ctx) => Dialog(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black,
                      Color(0xFF004d40),
                      Colors.black
                      ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Verify',
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                          ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Please check your email',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Close',
                          style: TextStyle(color: Colors.grey[800],fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
          Navigator.pop(context);
        } 
      } catch (error) {
          await showDialog(
            context: context,
            builder: (ctx) => Dialog(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF8B0000),
                      Colors.black,
                      Color(0xFF8B0000),
                      ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Error',
                        style: TextStyle(
                          color: Colors.white, 
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                          ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        error.toString(),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Close',
                          style: TextStyle(color: Colors.grey[800],fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/wallpaper.jpg'),
          fit: BoxFit.cover,
            ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 450.0),
                ElevatedButton(
                  onPressed: () {
                    loginEmailController.clear();
                    loginPasswordController.clear();
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return StatefulBuilder(
                          builder: (context, setStateDialog){
                        return AlertDialog(
                          backgroundColor: Colors.white.withOpacity(0.8),
                          scrollable: true,
                          title: const Center(
                            child: Text(
                              'LOGIN',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ),
                          content: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                MyTextField(
                                  controller: loginEmailController,
                                  hintText: 'Email',
                                  obscureText: false,
                                ),
                                const SizedBox(height: 10,),
                                MyTextField(
                                  controller: loginPasswordController,
                                  hintText: 'Password',
                                  obscureText: true,
                                ),
                                const SizedBox(height: 5,),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: GestureDetector(
                                    onTap: () async{
                                      if(loginEmailController.text.isEmpty)
                                      {
                                        await showDialog(
                                          context: context,
                                          builder: (ctx) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.black,
                                                    Color(0xFF004d40),
                                                    Colors.black
                                                    ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius: BorderRadius.circular(15.0),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.all(20),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'FORGOT PASSWORD?',
                                                      style: TextStyle(
                                                        color: Colors.white, 
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold
                                                        ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Text(
                                                      'Please Enter your email',
                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                                    ),
                                                    SizedBox(height: 20),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text(
                                                        'Close',
                                                        style: TextStyle(color: Colors.grey[800],fontSize: 16, fontWeight: FontWeight.bold),
                                                        ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          )
                                        );
                                      }
                                      else
                                      {
                                        await _auth.sendPasswordResetEmail(email: loginEmailController.text);
                                        await showDialog(
                                          context: context,
                                          builder: (ctx) => Dialog(
                                            backgroundColor: Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(15.0),
                                            ),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                 gradient: LinearGradient(
                                                  colors: [
                                                    Colors.black,
                                                    Color(0xFF004d40),
                                                    Colors.black
                                                    ],
                                                 ),
                                                borderRadius: BorderRadius.circular(15.0),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(20.0),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'FORGOT PASSWORD?',
                                                      style: TextStyle(
                                                        color: Colors.white, 
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold
                                                        ),
                                                    ),
                                                    SizedBox(height: 20),
                                                    Text(
                                                      'Please check your email',
                                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                                    ),
                                                    SizedBox(height: 20),
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.of(context).pop();
                                                      },
                                                      child: Text(
                                                        'Close',
                                                        style: TextStyle(color: Colors.grey[800],fontSize: 16, fontWeight: FontWeight.bold),
                                                        ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        color: Colors.purple,
                                        fontWeight: FontWeight.w600
                                        ),
                                      ),
                                  )
                                ),
                                const SizedBox(height:10.0),
                                isLoading ? const CircularProgressIndicator() :
                                ElevatedButton(
                                  onPressed: () async {
                                    setStateDialog(()=> isLoading=true);
                                    await signIn();
                                    setStateDialog(()=> isLoading=false);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[900],
                                  ),
                                  child: const Text('SUBMIT', style: TextStyle(color: Colors.white),),
                                ),
                              ],
                            ),
                          ),
                        );
                          }
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black54,
                    minimumSize: const Size(135, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'LOGIN',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
                const SizedBox(height: 5.0),
                ElevatedButton(
                  onPressed: () {
                    registerEmailController.clear();
                    registerPasswordController.clear();
                    confirmPasswordController.clear();
                    selectedGender = '';
                    showDialog(
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(
                          builder: (context, setStateDialog){
                        return AlertDialog(
                          scrollable: true,
                          backgroundColor: Colors.white.withOpacity(0.8),
                          title: const Center(
                            child: Text(
                              'REGISTER',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ),
                          content: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                MyTextField(
                                  controller: registerEmailController,
                                  hintText: 'Email',
                                  obscureText: false,
                                ),
                                const SizedBox(height: 10.0,),
                                MyTextField(
                                  controller: registerPasswordController,
                                  hintText: 'Password',
                                  obscureText: true,
                                ),
                                const SizedBox(height:10.0),
                                MyTextField(
                                  controller: confirmPasswordController,
                                  hintText: 'Confirm Password',
                                  obscureText: true,
                                ),
                                const SizedBox(height: 10.0,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Radio<String>(
                                      value: 'Male',
                                      groupValue: selectedGender,
                                      onChanged: (String? value) {
                                        setStateDialog(() {
                                          selectedGender = value!;
                                        });
                                      },
                                      activeColor: Colors.blue,
                                    ),
                                    const Text('Male'),
                                    const SizedBox(width: 15.0,),
                                    Radio<String>(
                                      value: 'Female',
                                      groupValue: selectedGender,
                                      onChanged: (String? value) {
                                        setStateDialog(() {
                                          selectedGender = value!;
                                        });
                                      },
                                      activeColor: Colors.blue,
                                    ),
                                    const Text('Female'),
                                  ],
                                ),
                                const SizedBox(height: 15.0,),
                                isLoading ? const CircularProgressIndicator():
                                ElevatedButton(
                                  onPressed: () async {
                                    setStateDialog(()=> isLoading=true);
                                    await signUp();
                                    // Navigator.pop(context);
                                    setStateDialog(()=> isLoading=false);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[900],
                                  ),
                                  child: const Text('SUBMIT', style: TextStyle(color: Colors.white),),
                                ),
                              ],
                            ),
                          ),
                        );
                        }
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black54,
                    minimumSize: const Size(100, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    'REGISTER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

