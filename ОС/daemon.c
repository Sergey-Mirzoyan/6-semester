#include <syslog.h>
#include <fcntl.h>
#include <sys/resource.h>

#include <signal.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include <arpa/inet.h>
#include <string.h>
#include <stdarg.h>
#include <errno.h>


//FILE *mylog;
//const char mylogname[128] = "/home/artalus/err.txt";
const char demonname[64] = "MyDemon";
#define LOCKFILE "/var/run/MyDemon.pid"

int sock;				//�������� ���������� ������, � �������
						//����� �������
struct sockaddr_in addr;	//�����, ��������� � ���� �������

//������ ���������� ����� ��������� � ����� �����
void MyPrint(const char* format, ...)
{
	char message[512];
	va_list ap;
	va_start( ap, format );
	vsnprintf( message, 512, format, ap );
	va_end( ap );
	
	//��������� �����
	sock = socket( AF_INET, SOCK_DGRAM, IPPROTO_UDP );
	
	//�������� ����� �����, ���������, ������, ��� ������,
	//�� ������, ������������� �������
	sendto( sock, message, strlen(message), 0,
		(struct sockaddr*) &addr, sizeof(addr) );
	
	close( sock ); //��������� �����
	
	//fprintf( mylog, "%s: %s\n", demonname, message );
	//fflush( mylog );
}

//���������� � �������� �������:
//������ ����������� ������ (1),
//������ �����������(-1),
//�������� ����������� (0)
int demonize(const char *process_name)
{
	int i;
		
	MyPrint( "fork" );
	//������� ������ � ��������� ������� - �� ����� ��������
	//������� ������, ��� ��������� ������� setsid
	int pid = fork();
	if ( pid < 0 )
	{
		MyPrint( "ERROR: fork" );
		return -1;
	}
	if ( pid != 0 ) //parent
		return 1;
	
	//��������� ��� � ����� ������ - ���������� ������� ������,
	//������� ������ � �������� ������������ ���������
	setsid();
	
	//���������� ������ ������ ���������
	struct sigaction sa; //����� ��������� �������� ��� ��������:
	sa.sa_handler = SIG_IGN; //������������ ������
	sigemptyset( &sa.sa_mask ); //���������� �����
	sa.sa_flags = 0;
	
	MyPrint( "sigaction" );
	if ( sigaction(SIGHUP, &sa, NULL) < 0 )
	{
		MyPrint( "ERROR: can't ignore SIGHUP" );
		return -1;
	}
	
	//������ ���� - ����� ������ � ������5
	/*pid = fork();
	if ( pid < 0 )
	{
		fprintf( mylog, "%s: second fork error", process_name );
		fflush( mylog );
		exit(1);
	}
	if ( pid != 0 )
		exit(0); //second parent*/
	
	MyPrint( "changing dir" );
	//������ ���������� �� / ����� ��� ������������� ����� ����
	//������������� �������� �������, �� ������� ���������� �����
	if ( chdir("/") < 0 )
	{
		MyPrint( "ERROR: can't change directory" );
		return -1;
	}
	

	MyPrint( "umask and getrlimit\n" );
	umask(0); //�������� ������ ����� ������� � ������, ����� ���
	//�� ������� � ��������������� ���������
	
	//�������� ������������ ���������� ������������
	struct rlimit rl;
	if ( getrlimit(RLIMIT_NOFILE, &rl) < 0 ) 
	{
		MyPrint( "ERROR: couldn't get max number of fd" );
		return -1;
	}
	if ( rl.rlim_max == RLIM_INFINITY )
		rl.rlim_max = 1024;
	
	//�������� �� ���� ������������ � ��������� �� - ����� �� ������
	//����������������� � ������������� ������
	for (i = 0; i < rl.rlim_max; ++i)
	{
		if ( i != sock ) //����� ���-������, ����� ���� ���� ������
			close(i);
	}
	MyPrint( "\n" );
	
	//��������� ������ ��� �������� �����������, ����� ������������
	//������� ������\������ �� ����������� ����\����� �� ���������
	//�������
	int fd0, fd1, fd2;
	fd0 = open( "/dev/null", O_RDWR );
	fd1 = dup(0); //��������� �����������
	fd2 = dup(0);
	
	//�������� ������ � ������ � /var/log/syslog
	openlog( process_name, LOG_CONS, LOG_DAEMON );
	if ( fd0 != 0 || fd1 != 1 || fd2 != 2)
	{
		MyPrint( "ERROR: Incorrect file descriptors 0,1,2" );
		syslog( LOG_ERR, "incorrect fd: %d %d %d", fd0, fd1, fd2 );
		return -1;
	}
	MyPrint( "Demonizing finished." );
	return 0;
}

//������������ ������ ������ � ������������ ����������
//��������� ����������, ���� �� ����� ������� ����,
//���������� 1, ���� ���� ��� "�����",
//0, ���� ������ ��������
int already_running(void)
{
#define BUFLEN 8
	int fd;
	char buf[BUFLEN];
	
	fd = open( LOCKFILE, O_RDWR|O_CREAT, S_IRUSR|S_IWUSR|S_IRGRP|S_IROTH );
	if (fd < 0)
	{
		MyPrint( "ERROR: unable to open %s: %s", LOCKFILE, strerror(errno) );
		syslog( LOG_ERR, "unable to open %s: %s", LOCKFILE, strerror(errno) );
		exit(1);
	}
	
	flock( fd, LOCK_EX|LOCK_NB );
	if ( errno == EWOULDBLOCK )
	{
		MyPrint( ">>> Can't lock file %s: %s\n>>> Is demon already launched?", LOCKFILE, strerror(errno) );
		syslog(LOG_ERR, "unable to lock %s: %s", LOCKFILE, strerror(errno));
		close(fd);
		return 1;
	}
	
	MyPrint( "%d - Successfully locked the file.", getpid() );
	snprintf( buf, BUFLEN, "%d", getpid() );
	write( fd, buf, strlen(buf) );
	return 0;
}

void demonFunc()
{
	MyPrint( "(%d) timestamp...", getpid() );
	syslog( LOG_INFO, "(%d) timestamp...\n", getpid() );
	sleep(3);
}

int main(void)
{
	addr.sin_addr.s_addr = 0x0100007f;
	addr.sin_port = htons(7777);
	addr.sin_family = AF_INET;
	
	
	printf( "demonizing...\n" );
	int d = demonize( demonname );
	if ( d > 0 )
	{
		MyPrint( "Parent: finished successfully" );
		return 0;
	}
	else if ( d < 0 )
	{
		MyPrint( "Parent: something went wrong!" );
		return 1;
	}
	
	if ( already_running() )
	{
		return 1;
	}
	MyPrint( "Successfully demonized." );
	
	while ( 1 )
	{
		demonFunc();
	}
}