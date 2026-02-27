import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsWebViewScreen extends StatefulWidget {
  const TermsWebViewScreen({super.key});

  @override
  State<TermsWebViewScreen> createState() => _TermsWebViewScreenState();
}

class _TermsWebViewScreenState extends State<TermsWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  static const String _termsHtml = '''
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Conditions Générales - smartPharma</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      font-size: 14px;
      color: #333;
      padding: 20px;
      line-height: 1.6;
      background: #fff;
    }
    h1 { font-size: 22px; color: #000; margin-bottom: 4px; }
    h2 { font-size: 17px; color: #000; margin-top: 24px; }
    h3 { font-size: 15px; color: #000; margin-top: 16px; }
    p, li { color: #595959; font-size: 14px; }
    ul { padding-left: 20px; }
    ul li { margin-bottom: 8px; }
    .subtitle { color: #595959; font-size: 13px; margin-bottom: 24px; }
    a { color: #3030F1; word-break: break-word; }
    hr { border: none; border-top: 1px solid #eee; margin: 16px 0; }
  </style>
</head>
<body>

<h1>TERMS AND CONDITIONS</h1>
<p class="subtitle"><strong>Last updated</strong> January 01, 2026</p>

<h2>AGREEMENT TO OUR LEGAL TERMS</h2>
<p>We operate the mobile application <strong>smartPharma</strong> (the "<strong>App</strong>"), as well as any other related products and services that refer or link to these legal terms (collectively, the "<strong>Services</strong>").</p>
<p>These Legal Terms constitute a legally binding agreement between you and smartPharma, concerning your access to and use of the Services. You agree that by accessing the Services, you have read, understood, and agreed to be bound by all of these Legal Terms. IF YOU DO NOT AGREE WITH ALL OF THESE LEGAL TERMS, THEN YOU ARE EXPRESSLY PROHIBITED FROM USING THE SERVICES AND YOU MUST DISCONTINUE USE IMMEDIATELY.</p>
<p>The Services are intended for users who are at least 13 years of age.</p>
<p>We recommend that you keep a copy of these Legal Terms for your records.</p>

<h2>1. OUR SERVICES</h2>
<p>The information provided when using the Services is not intended for distribution to or use by any person or entity in any jurisdiction or country where such distribution or use would be contrary to law or regulation.</p>

<h2>2. INTELLECTUAL PROPERTY RIGHTS</h2>
<h3>Our intellectual property</h3>
<p>We are the owner or the licensee of all intellectual property rights in our Services, including all source code, databases, functionality, software, app designs, audio, video, text, photographs, and graphics in the Services (collectively, the "<strong>Content</strong>"), as well as the trademarks, service marks, and logos contained therein (the "<strong>Marks</strong>").</p>
<p>Our Content and Marks are protected by copyright and trademark laws and treaties around the world.</p>

<h3>Your use of our Services</h3>
<p>Subject to your compliance with these Legal Terms, we grant you a non-exclusive, non-transferable, revocable license to access the Services solely for your personal, non-commercial use.</p>
<p>Except as set out in this section, no part of the Services and no Content or Marks may be copied, reproduced, republished, uploaded, posted, publicly displayed, encoded, translated, transmitted, distributed, sold, licensed, or otherwise exploited for any commercial purpose whatsoever, without our express prior written permission.</p>

<h3>Your submissions</h3>
<p>By directly sending us any question, comment, suggestion, idea, feedback, or other information about the Services ("<strong>Submissions</strong>"), you agree to assign to us all intellectual property rights in such Submission.</p>
<p><strong>You are responsible for what you post or upload.</strong> You confirm that you will not post, send, publish, upload, or transmit through the Services any Submission that is illegal, harassing, hateful, harmful, defamatory, obscene, abusive, discriminatory, threatening, sexually explicit, false, inaccurate, deceitful, or misleading.</p>

<h2>3. USER REPRESENTATIONS</h2>
<p>By using the Services, you represent and warrant that:</p>
<ul>
  <li>All registration information you submit will be true, accurate, current, and complete.</li>
  <li>You will maintain the accuracy of such information and promptly update it as necessary.</li>
  <li>You have the legal capacity and you agree to comply with these Legal Terms.</li>
  <li>You are not under the age of 13.</li>
  <li>You will not access the Services through automated or non-human means.</li>
  <li>You will not use the Services for any illegal or unauthorized purpose.</li>
  <li>Your use of the Services will not violate any applicable law or regulation.</li>
</ul>

<h2>4. USER REGISTRATION</h2>
<p>You may be required to register to use the Services. You agree to keep your password confidential and will be responsible for all use of your account and password. We reserve the right to remove, reclaim, or change a username you select if we determine, in our sole discretion, that such username is inappropriate, obscene, or otherwise objectionable.</p>

<h2>5. PROHIBITED ACTIVITIES</h2>
<p>You may not access or use the Services for any purpose other than that for which we make the Services available. As a user of the Services, you agree NOT to:</p>
<ul>
  <li>Systematically retrieve data or other content from the Services to create or compile a collection, compilation, database, or directory without written permission from us.</li>
  <li>Trick, defraud, or mislead us and other users, especially in any attempt to learn sensitive account information such as user passwords.</li>
  <li>Circumvent, disable, or otherwise interfere with security-related features of the Services.</li>
  <li>Disparage, tarnish, or otherwise harm, in our opinion, us and/or the Services.</li>
  <li>Use any information obtained from the Services in order to harass, abuse, or harm another person.</li>
  <li>Make improper use of our support services or submit false reports of abuse or misconduct.</li>
  <li>Use the Services in a manner inconsistent with any applicable laws or regulations.</li>
  <li>Upload or transmit viruses, Trojan horses, or other material that interferes with any party's uninterrupted use and enjoyment of the Services.</li>
  <li>Engage in any automated use of the system, such as using scripts to send comments or messages, or using any data mining, robots, or similar data gathering and extraction tools.</li>
  <li>Attempt to impersonate another user or person or use the username of another user.</li>
  <li>Use the Services as part of any effort to compete with us or otherwise use the Services for any revenue-generating endeavor or commercial enterprise.</li>
  <li><strong>Impersonate a pharmacist or healthcare professional without proper credentials.</strong></li>
  <li><strong>Submit false or misleading medical or pharmaceutical information.</strong></li>
  <li>Sell or otherwise transfer your profile.</li>
</ul>

<h2>6. USER GENERATED CONTRIBUTIONS</h2>
<p>When you create or make available any Contributions, you represent and warrant that:</p>
<ul>
  <li>The creation, distribution, transmission, public display, or performance, and the accessing, downloading, or copying of your Contributions do not and will not infringe the proprietary rights of any third party.</li>
  <li>Your Contributions are not false, inaccurate, or misleading.</li>
  <li>Your Contributions are not unsolicited or unauthorized advertising, promotional materials, spam, mass mailings, or other forms of solicitation.</li>
  <li>Your Contributions are not obscene, lewd, lascivious, filthy, violent, harassing, libelous, slanderous, or otherwise objectionable.</li>
  <li>Your Contributions do not violate any applicable law, regulation, or rule.</li>
  <li>Your Contributions do not violate the privacy or publicity rights of any third party.</li>
</ul>

<h2>7. CONTRIBUTION LICENSE</h2>
<p>You and Services agree that we may access, store, process, and use any information and personal data that you provide and your choices (including settings).</p>
<p>By submitting suggestions or other feedback regarding the Services, you agree that we can use and share such feedback for any purpose without compensation to you.</p>
<p>We do not assert any ownership over your Contributions. You retain full ownership of all of your Contributions and any intellectual property rights associated with your Contributions.</p>

<h2>8. MOBILE APPLICATION LICENSE</h2>
<h3>Use License</h3>
<p>If you access the Services via the App, then we grant you a revocable, non-exclusive, non-transferable, limited right to install and use the App on wireless electronic devices owned or controlled by you, strictly in accordance with the terms and conditions of this mobile application license contained in these Legal Terms. You shall not:</p>
<ol>
  <li>Decompile, reverse engineer, disassemble, attempt to derive the source code of, or decrypt the App.</li>
  <li>Make any modification, adaptation, improvement, enhancement, translation, or derivative work from the App.</li>
  <li>Violate any applicable laws, rules, or regulations in connection with your access or use of the App.</li>
  <li>Use the App for any revenue-generating endeavor, commercial enterprise, or other purpose for which it is not designed or intended.</li>
  <li>Use the App for creating a product, service, or software that is, directly or indirectly, competitive with or in any way a substitute for the App.</li>
</ol>

<h3>Apple and Android Devices</h3>
<p>The following terms apply when you use the App obtained from either the Apple Store or Google Play: the license granted to you for our App is limited to a non-transferable license to use the application on a device that utilizes the Apple iOS or Android operating systems, as applicable, and in accordance with the usage rules set forth in the applicable App Distributor's terms of service.</p>

<h2>9. SOCIAL MEDIA</h2>
<p>As part of the functionality of the Services, you may link your account with online accounts you have with third-party service providers (each such account, a "<strong>Third-Party Account</strong>") such as Google or Facebook. You represent and warrant that you are entitled to disclose your Third-Party Account login information to us and/or grant us access to your Third-Party Account, without breach by you of any of the terms and conditions that govern your use of the applicable Third-Party Account.</p>

<h2>10. SERVICES MANAGEMENT</h2>
<p>We reserve the right, but not the obligation, to: (1) monitor the Services for violations of these Legal Terms; (2) take appropriate legal action against anyone who violates the law or these Legal Terms; (3) in our sole discretion, refuse, restrict access to, limit the availability of, or disable any of your Contributions or any portion thereof; (4) remove from the Services or otherwise disable all files and content that are excessive in size or are in any way burdensome to our systems; and (5) otherwise manage the Services in a manner designed to protect our rights and property.</p>

<h2>11. PRIVACY POLICY</h2>
<p>We care about data privacy and security. By using the Services, you agree to be bound by our Privacy Policy. Please be advised the Services are hosted in Morocco. If you access the Services from any other region of the world with laws or other requirements governing personal data collection, use, or disclosure that differ from applicable laws in Morocco, then through your continued use of the Services, you are transferring your data to Morocco, and you expressly consent to have your data transferred to and processed in Morocco.</p>

<h2>12. TERM AND TERMINATION</h2>
<p>These Legal Terms shall remain in full force and effect while you use the Services. WE RESERVE THE RIGHT TO, IN OUR SOLE DISCRETION AND WITHOUT NOTICE OR LIABILITY, DENY ACCESS TO AND USE OF THE SERVICES (INCLUDING BLOCKING CERTAIN IP ADDRESSES), TO ANY PERSON FOR ANY REASON OR FOR NO REASON, INCLUDING WITHOUT LIMITATION FOR BREACH OF ANY REPRESENTATION, WARRANTY, OR COVENANT CONTAINED IN THESE LEGAL TERMS OR OF ANY APPLICABLE LAW OR REGULATION.</p>
<p>If we terminate or suspend your account for any reason, you are prohibited from registering and creating a new account under your name, a fake or borrowed name, or the name of any third party.</p>

<h2>13. MODIFICATIONS AND INTERRUPTIONS</h2>
<p>We reserve the right to change, modify, or remove the contents of the Services at any time or for any reason at our sole discretion without notice. We cannot guarantee the Services will be available at all times.</p>

<h2>14. GOVERNING LAW</h2>
<p>These Legal Terms shall be governed by and defined following the laws of Morocco. You irrevocably consent that the courts of Morocco shall have exclusive jurisdiction to resolve any dispute which may arise in connection with these Legal Terms.</p>

<h2>15. DISPUTE RESOLUTION</h2>
<h3>Informal Negotiations</h3>
<p>To expedite resolution and control the cost of any dispute, controversy, or claim related to these Legal Terms, the Parties agree to first attempt to negotiate any Dispute informally for at least 30 days before initiating arbitration.</p>

<h3>Restrictions</h3>
<p>The Parties agree that any arbitration shall be limited to the Dispute between the Parties individually. To the full extent permitted by law, no arbitration shall be joined with any other proceeding; there is no right or authority for any Dispute to be arbitrated on a class-action basis.</p>

<h2>16. CORRECTIONS</h2>
<p>There may be information on the Services that contains typographical errors, inaccuracies, or omissions. We reserve the right to correct any errors, inaccuracies, or omissions and to change or update the information on the Services at any time, without prior notice.</p>

<h2>17. DISCLAIMER</h2>
<p>THE SERVICES ARE PROVIDED ON AN AS-IS AND AS-AVAILABLE BASIS. TO THE FULLEST EXTENT PERMITTED BY LAW, WE DISCLAIM ALL WARRANTIES, EXPRESS OR IMPLIED, IN CONNECTION WITH THE SERVICES AND YOUR USE THEREOF, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.</p>

<h2>18. LIMITATIONS OF LIABILITY</h2>
<p>IN NO EVENT WILL WE OR OUR DIRECTORS, EMPLOYEES, OR AGENTS BE LIABLE TO YOU OR ANY THIRD PARTY FOR ANY DIRECT, INDIRECT, CONSEQUENTIAL, EXEMPLARY, INCIDENTAL, SPECIAL, OR PUNITIVE DAMAGES, INCLUDING LOST PROFIT, LOST REVENUE, LOSS OF DATA, OR OTHER DAMAGES ARISING FROM YOUR USE OF THE SERVICES.</p>

<h2>19. INDEMNIFICATION</h2>
<p>You agree to defend, indemnify, and hold us harmless, including our subsidiaries, affiliates, and all of our respective officers, agents, partners, and employees, from and against any loss, damage, liability, claim, or demand, including reasonable attorneys' fees and expenses, made by any third party due to or arising out of: (1) use of the Services; (2) breach of these Legal Terms; (3) any breach of your representations and warranties set forth in these Legal Terms; (4) your violation of the rights of a third party, including but not limited to intellectual property rights; or (5) any overt harmful act toward any other user of the Services.</p>

<h2>20. USER DATA</h2>
<p>We will maintain certain data that you transmit to the Services for the purpose of managing the performance of the Services, as well as data relating to your use of the Services. You are solely responsible for all data that you transmit or that relates to any activity you have undertaken using the Services.</p>

<h2>21. ELECTRONIC COMMUNICATIONS, TRANSACTIONS, AND SIGNATURES</h2>
<p>Visiting the Services, sending us emails, and completing online forms constitute electronic communications. You consent to receive electronic communications, and you agree that all agreements, notices, disclosures, and other communications we provide to you electronically satisfy any legal requirement that such communication be in writing.</p>

<h2>22. MISCELLANEOUS</h2>
<p>These Legal Terms and any policies or operating rules posted by us on the Services constitute the entire agreement and understanding between you and us. Our failure to exercise or enforce any right or provision of these Legal Terms shall not operate as a waiver of such right or provision. These Legal Terms operate to the fullest extent permissible by law.</p>

<h2>23. CONTACT US</h2>
<p>In order to resolve a complaint regarding the Services or to receive further information regarding use of the Services, please contact us at:</p>
<p><strong>smartPharma</strong><br>
Email: <a href="mailto:contact@smartpharma.app">contact@smartpharma.app</a></p>

<br>
<hr>
<p style="font-size:12px; color:#999; text-align:center;">These Terms and Conditions were created using Termly's Terms and Conditions Generator.</p>

</body>
</html>
''';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadHtmlString(_termsHtml);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Conditions Générales',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
