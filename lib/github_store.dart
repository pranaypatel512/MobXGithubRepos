import 'package:github/github.dart';
import 'package:mobx/mobx.dart';

part 'github_store.g.dart';

class GithubStore = _GithubStore with _$GithubStore;

abstract class _GithubStore with Store{
  final GitHub client = GitHub();

  static ObservableFuture<List<Repository>> emptyResponse = ObservableFuture.value([]);

  @observable
  ObservableFuture<List<Repository>> fetchReposFuture = emptyResponse;

  List<Repository> repositories = [];

  @observable
  String user='';

  @computed
  bool get hasResults =>
      fetchReposFuture != emptyResponse &&
      fetchReposFuture.status == FutureStatus.fulfilled;

  @action
  void setUser(String userName){
    fetchReposFuture = emptyResponse;
    user = userName;
  }

  @action
  Future<List<Repository>> fetchRepositories() async {
    repositories = [];
    final repoFuture = client.repositories.listUserRepositories(user).toList();
    fetchReposFuture = ObservableFuture(repoFuture);

    return repositories = await repoFuture;
  }
}