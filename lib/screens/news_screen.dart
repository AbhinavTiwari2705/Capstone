import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:krishimitra/models/news_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  List<NewsArticle> _news = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchNews();
  }

  Future<void> _fetchNews() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get API key from environment variables
      final apiKey = dotenv.env['NEWS_API_KEY'] ?? '';
      print('API Key: $apiKey');
      if (apiKey.isEmpty) {
        throw Exception('NEWS_API_KEY not found in environment variables');
      }
      
      final response = await http.get(
        Uri.parse('https://newsdata.io/api/1/news?apikey=$apiKey&country=in&category=business&q=farmer'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Parsed data: $data');
        
        if (data['status'] == 'success') {
          final articles = data['results'] as List;
          print('Found ${articles.length} articles');
          
          setState(() {
            _news = articles.map((article) => NewsArticle.fromJson(article)).toList();
            _isLoading = false;
          });
        } else {
          setState(() {
            _error = 'API returned status: ${data['status']}';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _error = 'Failed to fetch news';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open article')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(AppLocalizations.of(context)!.newsLoadError),
            ElevatedButton(
              onPressed: _fetchNews,
              child: Text(AppLocalizations.of(context)!.retry),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.businessNews),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchNews,
        child: ListView.builder(
          itemCount: _news.length,
          itemBuilder: (context, index) {
            final article = _news[index];
            return Card(
              margin: EdgeInsets.all(8),
              child: InkWell(
                onTap: () => _launchURL(article.url),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (article.urlToImage.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                        child: Image.network(
                          article.urlToImage,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(height: 200, color: Colors.grey[300]),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            article.title,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            article.description,
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                article.source,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                article.publishedAt.substring(0, 10),
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
