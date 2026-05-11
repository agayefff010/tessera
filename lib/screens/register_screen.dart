import 'package:flutter/material.dart';

void main() {
  runApp(const RegisterScreen());
}

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Register Menu",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Daxil olun və ya hesab yaradın",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 40),

                      buildInput(
                        label: "Email",
                        hint: "Email adresinizi bura qeyd edin",
                      ),

                      const SizedBox(height: 25),

                      buildInput(
                        label: "Ad",
                        hint: "Adınızı bura qeyd edin",
                      ),

                      const SizedBox(height: 25),

                      buildInput(
                        label: "Telefon",
                        hint: "+994 ** *** ** **",
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        'Qeydiyyatdan keçməklə siz loyallıq proqramına daxil olur,\n'
                        '"İstifadə şərtləri" və "Məxfilik siyasəti" ilə razılaşırsınız.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: false,
                            onChanged: (value) {},
                          ),

                          const Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(top: 12),
                              child: Text(
                                "Yeni imtiyazlar və sevimli brendlərin kolleksiyalarını qaçırmamaq üçün bülletenə abunə olun.",
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Qeydiyyatdan keç",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Center(
                        child: Text(
                          "yaxud",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      socialButton(
                        icon: Icons.g_mobiledata,
                        text: "Google ilə daxil ol",
                      ),

                      const SizedBox(height: 15),

                      socialButton(
                        icon: Icons.apple,
                        text: "Apple ilə daxil ol",
                      ),

                      const SizedBox(height: 15),

                      socialButton(
                        icon: Icons.facebook,
                        text: "Facebook ilə daxil ol",
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildInput({
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Colors.grey,
            ),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey,
              ),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.black,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget socialButton({
    required IconData icon,
    required String text,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.black26),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
        ),
        onPressed: () {},
        icon: Icon(
          icon,
          color: Colors.black,
          size: 28,
        ),
        label: Text(
          text,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}