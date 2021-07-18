# Form Register API PoC


## Tech Stack

- [Kong - API Gateway](https://github.com/kong/kong)
- [ngx_lua - API](https://github.com/openresty/lua-nginx-module)
- [ktserver - Database](https://dbmx.net/kyototycoon/command.html#ktserver)

## Architecture Design

```plantuml
@startuml infra

!include <logos/lua>
!include <logos/memcached>

' skinparam backgroundColor #f5f6fa
skinparam handwritten true
skinparam sequenceArrowThickness 2
skinparam roundcorner 10
skinparam maxmessagesize 100
skinparam sequenceParticipant underline

skinparam maxCardWidth 200

actor User << User >>
actor User << User >>

agent App << Web or App >>

card Infrastructure {
    card Gateway {
        agent "<img:kong.png>" as Kong
    }

    card ktserver {
        agent "<$memcached>" as  kt1
        agent "<$memcached>" as  kt2
        agent "<$memcached>" as  kt3
    }

    card API {
        agent "<$lua>" as  api1
        agent "<$lua>" as  api2
    }
}

User <-right-> App
App <-right-> Kong

Kong <-[#blue]-> api1
Kong <-[#blue]-> api2

api1 <-[#green]right-> kt1
api1 <-[#green]right-> kt2
api1 <-[#green]right-> kt3

api2 <-[#green]right-> kt1
api2 <-[#green]right-> kt2
api2 <-[#green]right-> kt3

kt1 <-right-> kt2
kt2 <-down-> kt3
kt3 <--> kt1

@enduml
```

## Deploy API

```
docker-compose up -d
```

## Register API

```
curl -i http://127.0.0.1/v1/register\
    -d '{"id":"1234", "name":"John Farmer", "phone":"0812345678", "address":"7th Heven"}'
```


## DB report

```
docker exec kt1 ktremotemgr report -host kt1
```

## List Data

```
docker exec kt1 ktremotemgr list -host kt3 -pv
```

## Export Data

```
docker exec kt1 ktremotemgr list -host kt3 -pv > db.tsv
```

## Specification Recomemd

> Minimum Spec

|   |   |
|----|----|
| CPU | 4 Core |
| RAM | 8GB |
| SSD | 40GB |
| Network Bandwidth | 1Gbps |

## Load Testing Result

![wrk -t 4 -c 10k -d 15m](./wrk.png)


## Known Issue

Please generate unique id for load testing and disable rate-limiting plugins in [conf.d/kong.yml](conf.d/kong.yml) before run load testing
