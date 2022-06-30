import 'package:flutter/material.dart';
import 'package:mobx/mobx.dart';
import 'package:mobx_github_repos/github_store.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Github users Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GithubStore store = GithubStore();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text("Github users Demo"),
      ),
      body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            UserInput(store),
            ShowError(store),
            LoadingIndicator(store),
            RepositoryListView(store)
          ],
      )
    );
  }
}

class LoadingIndicator  extends StatelessWidget {
  const LoadingIndicator(this.store);


  final GithubStore store;

  @override
  Widget build(BuildContext context) => Observer(
      builder: (_) => store.fetchReposFuture.status == FutureStatus.pending
          ? const LinearProgressIndicator()
          : Container());

}

class UserInput extends StatelessWidget {
const UserInput(this.store, {Key? key}) : super(key: key);

final GithubStore store;

@override
Widget build(BuildContext context) => Row(
  children: <Widget>[
    Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: TextField(
          autocorrect: false,
          autofocus: true,
          onSubmitted: (String user) {
            store.setUser(user);
            store.fetchRepositories();
          },
        ),
      ),
    ),
    IconButton(
      icon: const Icon(Icons.search),
      onPressed: store.fetchRepositories,
    )
  ],
);
}

class ShowError extends StatelessWidget {
  const ShowError(this.store, {Key? key}) : super(key: key);

  final GithubStore store;

  @override
  Widget build(BuildContext context) => Observer(
      builder: (_) => store.fetchReposFuture.status == FutureStatus.rejected
          ? Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
        const Icon(
          Icons.warning,
          color: Colors.deepOrange,
        ),
        Container(
          width: 8,
        ),
        const Text(
          'Failed to fetch repos for',
          style: TextStyle(color: Colors.deepOrange),
        ),
        Text(
          store.user,
          style: const TextStyle(
              color: Colors.deepOrange, fontWeight: FontWeight.bold),
        )
      ])
          : Container());
}

class RepositoryListView  extends StatelessWidget {
  const RepositoryListView(this.store);
  final GithubStore store;

  @override
  Widget build(BuildContext context) => Expanded(child:
  Observer(builder: (_) {
    if(!store.hasResults){
      return Container();
    }

    if(store.repositories.isEmpty){
      return Row(mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        const Text("We could not find any repos for user:"),
        Text(
          store.user,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )
      ] ,
      );
    }

    return ListView.builder(itemCount: store.repositories.length,
        itemBuilder: (_,int index){
            final repo = store.repositories[index];
            return ListTile(
              title: Row(
                children: <Widget>[
                  Text(
                    repo.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(' (${repo.stargazersCount} ⭐️)'),
                ],
              ),
              subtitle: Text(repo.description ?? ''),
            );
        });

  })
  );

}


