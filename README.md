# TwinFleet — Plateforme multi-environnements NeoCargo

TP de groupe avancé — Mastère Cybersécurité IPSSI — Gestion des configurations & IaC.
Deux environnements jumeaux (**staging** et **prod**) construits à partir des **mêmes modules Terraform**
et configurés par les **mêmes rôles Ansible**. Seules les variables changent.

## Équipe
| Membre | Rôle principal |
|---|---|
| Ismael (nsid2003) | Mainteneur du dépôt, merge des PR, à compléter |
| Emmanuel | à compléter |
| Thierno | à compléter |

## Arborescence
```
terraform/modules/{network,compute,data}   modules réutilisables
terraform/environments/{staging,prod}      appels des modules + *.tfvars
ansible/roles/{webserver,monitoring}       rôles Ansible
ansible/inventory/aws_ec2.yml              inventaire dynamique
ansible/group_vars/{staging,prod}.yml      variables par environnement
docs/                                      schéma, rapport, IAM
```

## Règles de contribution
1. **Jamais de push sur `main`** : tout passe par une Pull Request.
2. **Une branche par fonctionnalité**, nommée `type/scope-description` :
   `feat/network-subnets`, `fix/compute-healthcheck`, `docs/rapport-git`, `ci/terraform-plan`.
3. **Commits conventionnels** : `type(scope): description`
   - types : `feat`, `fix`, `refactor`, `docs`, `chore`, `ci`, `test`
   - ex. : `feat(network): ajoute les sous-réseaux privés data`
4. **Revue obligatoire** par au moins un autre membre, avec un commentaire argumenté (pas juste « OK »).
5. **Merge** : effectué par le mainteneur une fois la PR approuvée et la CI verte.
6. **On ne supprime aucune branche ni PR** après merge (historique noté).
